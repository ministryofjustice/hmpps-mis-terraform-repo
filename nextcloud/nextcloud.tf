#-------------------------------------------------------------
### IAM Instance profile
#-------------------------------------------------------------
module "iam_instance_profile" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/instance_profile?ref=terraform-0.12"
  role   = module.iam_app_role.iamrole_name
}

#-------------------------------------------------------------
### IAM Policy
#-------------------------------------------------------------
module "iam_app_policy" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/rolepolicy?ref=terraform-0.12"
  policyfile = data.template_file.iam_policy_app.rendered
  rolename   = module.iam_app_role.iamrole_name
}

#-------------------------------------------------------------
### IAM Policy template file
#-------------------------------------------------------------
data "template_file" "iam_policy_app" {
  template = file("${path.module}/${local.ec2_role_policy_file}")
  vars = {
    nextcloud_s3_bucket_arn    = local.nextcloud_s3_bucket_arn
    wmt_bucket_name_prod       = local.wmt_bucket_name_prod
    wmt_bucket_name_pre_prod   = local.wmt_bucket_name_pre_prod
  }
}

#-------------------------------------------------------------
### EC2 Role
#-------------------------------------------------------------
module "iam_app_role" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/role?ref=terraform-0.12"
  policyfile = local.ec2_policy_file
  rolename   = "${local.short_environment_identifier}-${local.app_name}"
}

#-------------------------------------------------------------
### Userdata template
#-------------------------------------------------------------

data "template_file" "nextcloud_user_data" {
  template = file("user_data/bootstrap.sh")

  vars = {
    app_name                     = local.app_name
    mis_app_name                 = local.mis_app_name
    bastion_inventory            = local.bastion_inventory
    private_domain               = local.internal_domain
    private_zone_id              = local.private_zone_id
    account_id                   = data.terraform_remote_state.vpc.outputs.vpc_account_id
    environment_name             = local.environment_name
    env_identifier               = local.environment_identifier
    short_env_identifier         = local.short_environment_identifier
    ldap_elb_name                = local.ldap_elb_name
    ldap_port                    = local.ldap_port
    external_domain              = local.external_domain
    nextcloud_admin_user         = local.nextcloud_admin_user
    nextcloud_admin_pass_param   = local.nextcloud_admin_pass_param
    nextcloud_db_user_pass_param = local.nextcloud_db_user_pass_param
    efs_dns_name                 = local.efs_dns_name
    nextcloud_db_user            = local.nextcloud_db_user
    db_dns_name                  = local.db_dns_name
    ldap_bind_param              = "/${local.environment_name}/delius/apacheds/apacheds/ldap_admin_password"
    ldap_bind_user               = local.ldap_bind_user
    backup_bucket                = local.backup_bucket
    redis_address                = local.redis_address
    installer_user               = local.installer_user
    config_passw                 = local.config_passw
    mis_user                     = data.aws_ssm_parameter.user.value
    mis_user_pass_name           = "${local.environment_identifier}-${local.mis_app_name}-admin-password"
    reports_pass_name            = "${local.environment_identifier}-reports-admin-password"
    bosso_svc_passname           = "/${local.environment_name}/delius/${local.mis_app_name}-service-accounts/SVC_BOSSO-NDL/SVC_BOSSO-NDL_password"
    cidr_block_a_subnet          = local.cidr_block_a_subnet
    cidr_block_b_subnet          = local.cidr_block_b_subnet
    cidr_block_c_subnet          = local.cidr_block_c_subnet
    pwm_url                      = local.pwm_url
    strategic_pwm_url            = local.strategic_pwm_url
    environment_type             = var.environment_type
    region                       = var.region
    wmt_bucket_name_prod         = local.wmt_bucket_name_prod
    wmt_bucket_name_pre_prod     = local.wmt_bucket_name_pre_prod
  }
}

#-------------------------------------------------------------
### Create Nextcloud instance
#-------------------------------------------------------------

#Launch cfg
resource "aws_launch_configuration" "launch_cfg" {
  name_prefix          = "${var.environment_type}-nextcloud-launch-cfg-"
  image_id             = data.aws_ami.amazon_ami.id
  iam_instance_profile = module.iam_instance_profile.iam_instance_name
  instance_type        = var.nextcloud_instance_type
  security_groups = flatten([
    local.sg_bastion_in,
    local.sg_https_out,
    local.sg_mis_app_in,
    local.efs_security_groups,
    local.nextcloud_db_sg,
    local.nextcloud_samba_sg,
    local.sg_smtp_ses,
  ])
  enable_monitoring           = "true"
  associate_public_ip_address = false
  key_name                    = data.terraform_remote_state.common.outputs.common_ssh_deployer_key
  user_data                   = data.template_file.nextcloud_user_data.rendered
  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "null_data_source" "tags" {
  count = length(keys(local.tags))
  inputs = {
    key                 = element(keys(local.tags), count.index)
    value               = element(values(local.tags), count.index)
    propagate_at_launch = true
  }
}

#ASG
resource "aws_autoscaling_group" "asg" {
  name = "${var.environment_type}-${local.app_name}"
  vpc_zone_identifier = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
  launch_configuration = aws_launch_configuration.launch_cfg.id
  min_size             = var.nextcloud_instance_count
  max_size             = var.nextcloud_instance_count
  desired_capacity     = var.nextcloud_instance_count
  health_check_type    = "EC2"
  tags = [
    for key, value in merge(local.tags, {
      "Name" = "${var.environment_type}-${local.app_name}-asg"
    }) : {
      key                 = key
      value               = value
      propagate_at_launch = true
    }
  ]
  lifecycle {
    create_before_destroy = true
  }
}



#-------------------------------------------------------------
### LB attachments
#-------------------------------------------------------------

#nextcloud
resource "aws_autoscaling_attachment" "nextcloud_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = module.nextcloud_lb.environment_elb_id
}

#samba_lb
resource "aws_autoscaling_attachment" "samba_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = aws_elb.samba_lb.id
}

#-------------------------------------------------------------
### Cloudwatch log group
#-------------------------------------------------------------

resource "aws_cloudwatch_log_group" "httpd_access_logs" {
  name              = "/${var.environment_type}/${local.app_name}/access_log"
  retention_in_days = 14
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "httpd_error_logs" {
  name              = "/${var.environment_type}/${local.app_name}/error_log"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "nextcloud_logs" {
  name              = "/${var.environment_type}/${local.app_name}/nextcloud.log"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "samba_logs" {
  name              = "/${var.environment_type}/${local.app_name}/log.smbd"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "wmt_logs" {
  name              = "/${var.environment_type}/${local.app_name}/wmt_log"
  retention_in_days = 14
}
