terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/common/terraform.tfstate"
    region = "${var.region}"
  }
}


#-------------------------------------------------------------
### Getting the s3 details
#-------------------------------------------------------------
data "terraform_remote_state" "s3bucket" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/s3buckets/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the IAM details
#-------------------------------------------------------------
data "terraform_remote_state" "iam" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/iam/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the security groups details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the VPC details
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the http fs details
#-------------------------------------------------------------
data "terraform_remote_state" "http-file-server" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/http-file-server/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the ldap elb details
#-------------------------------------------------------------
data "terraform_remote_state" "ldap_elb_name" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting ACM Cert
#-------------------------------------------------------------
data "aws_acm_certificate" "http_fs_cert" {
  domain      = "*.${data.terraform_remote_state.common.external_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base CentOS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}




####################################################
# Locals
####################################################

locals {
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  internal_domain              = "${data.terraform_remote_state.vpc.private_zone_name}"
  private_zone_id              = "${data.terraform_remote_state.vpc.private_zone_id}"
  external_domain              = "${data.terraform_remote_state.vpc.public_zone_name}"
  region                       = "${var.region}"
  ssh_deployer_key             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  app_name                     = "http-fs"
  mis_app_name                 = "${data.terraform_remote_state.common.mis_app_name}"
  bastion_inventory            = "${var.bastion_inventory}"
  efs_dns_name                 = "${module.efs_share.efs_dns_name}"
  environment_identifier       = "${data.terraform_remote_state.common.environment_identifier}"
  short_environment_identifier = "${data.terraform_remote_state.common.short_environment_identifier}"
  ec2_policy_file              = "ec2_policy.json"
  ec2_role_policy_file         = "policies/ec2.json"
  sg_bastion_in                = "${data.terraform_remote_state.security-groups.sg_ssh_bastion_in_id}"
  sg_https_out                 = "${data.terraform_remote_state.security-groups.sg_https_out}"
  s3bucket                     = "${data.terraform_remote_state.s3bucket.s3bucket}"
  logs_bucket                  = "${data.terraform_remote_state.common.common_s3_lb_logs_bucket}"
  certificate_arn              = "${data.aws_acm_certificate.http_fs_cert.arn}"
  sg_mis_app_in                = "${data.terraform_remote_state.security-groups.sg_mis_app_in}"
  public_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
  public_subnet_ids            = ["${data.terraform_remote_state.common.public_subnet_ids}"]
  private_subnet_ids           = ["${data.terraform_remote_state.common.private_subnet_ids}"]
  sg_mis_samba                 = ["${data.terraform_remote_state.security-groups.sg_mis_samba}",]
  efs_security_groups          = ["${data.terraform_remote_state.security-groups.sg_mis_efs_in}",]
  tags                         = "${data.terraform_remote_state.vpc.tags}"
  fs_fqdn                      = "${data.terraform_remote_state.http-file-server.public_fqdn_http_fs_elb}"
  ldap_elb_name                = "${data.terraform_remote_state.ldap_elb_name.private_fqdn_readonly_ldap_elb}"
  ldap_port                    = "${data.terraform_remote_state.ldap_elb_name.ldap_port}"

}



#-------------------------------------------------------------
### IAM Instance profile
#-------------------------------------------------------------
module "iam_instance_profile" {
  source    = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//instance_profile"
  role      = "${module.iam_app_role.iamrole_name}"
}

#-------------------------------------------------------------
### IAM Policy
#-------------------------------------------------------------
module "iam_app_policy" {
  source        = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//rolepolicy"
  policyfile    = "${data.template_file.iam_policy_app.rendered}"
  rolename      = "${module.iam_app_role.iamrole_name}"
}


#-------------------------------------------------------------
### IAM Policy template file
#-------------------------------------------------------------
data "template_file" "iam_policy_app" {
  template = "${file("${path.module}/${local.ec2_role_policy_file}")}"
}


#-------------------------------------------------------------
### EC2 Role
#-------------------------------------------------------------
module "iam_app_role" {
  source        = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//role"
  policyfile    = "${local.ec2_policy_file}"
  rolename      = "${local.short_environment_identifier}-${local.app_name}"
}

#-------------------------------------------------------------
## Getting the admin username and password
#-------------------------------------------------------------
data "aws_ssm_parameter" "user" {
  name = "${local.environment_identifier}-${local.mis_app_name}-admin-user"
}

data "aws_ssm_parameter" "password" {
  name = "${local.environment_identifier}-${local.mis_app_name}-admin-password"
}


#-------------------------------------------------------------
### Userdata template
#-------------------------------------------------------------

data "template_file" "http_fs_user_data" {
  template = "${file("user_data/bootstrap.sh")}"

  vars {
    app_name              = "${local.app_name}"
    bastion_inventory     = "${local.bastion_inventory}"
    private_domain        = "${local.internal_domain}"
    private_zone_id       = "${local.private_zone_id}"
    account_id            = "${data.terraform_remote_state.vpc.vpc_account_id}"
    environment_name      = "${local.environment_name}"
    env_identifier        = "${local.environment_identifier}"
    short_env_identifier  = "${local.short_environment_identifier}"
    efs_dns_name          = "${local.efs_dns_name}"
    mis_user              = "${data.aws_ssm_parameter.user.value}"
    mis_user_pass_name    = "${local.environment_identifier}-${local.mis_app_name}-admin-password"
    fs_fqdn               = "${local.fs_fqdn}"
    ldap_elb_name         = "${local.ldap_elb_name}"
    ldap_port             = "${local.ldap_port}"

  }
}

#-------------------------------------------------------------
### Create Apache Instance and Samba share
#-------------------------------------------------------------

#Launch cfg
resource "aws_launch_configuration" "launch_cfg" {
  name_prefix          = "${local.short_environment_identifier}-http-launch-cfg-"
  image_id             = "${data.aws_ami.amazon_ami.id}"
  iam_instance_profile = "${module.iam_instance_profile.iam_instance_name}"
  instance_type        = "${var.http_instance_type}"
  security_groups      = [
    "${local.sg_bastion_in}",
    "${local.sg_https_out}",
    "${local.efs_security_groups}",
    "${local.sg_mis_app_in}",
    "${local.sg_mis_samba}",
  ]
  enable_monitoring    = "true"
  associate_public_ip_address = false
  key_name                    = "${data.terraform_remote_state.common.common_ssh_deployer_key}"
  user_data                   = "${data.template_file.http_fs_user_data.rendered}"
  root_block_device {
    volume_type        = "gp2"
    volume_size        = 50
  }
  lifecycle {
    create_before_destroy = true
  }
}


data "null_data_source" "tags" {
  count = "${length(keys(var.tags))}"
  inputs = {
    key                 = "${element(keys(var.tags), count.index)}"
    value               = "${element(values(var.tags), count.index)}"
    propagate_at_launch = true
  }
}

#ASG
resource "aws_autoscaling_group" "asg" {
  name                      = "${local.environment_identifier}-${local.app_name}"
  vpc_zone_identifier       = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
	data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"]
  launch_configuration      = "${aws_launch_configuration.launch_cfg.id}"
  min_size                  = "${var.instance_count}"
  max_size                  = "${var.instance_count}"
  desired_capacity          = "${var.instance_count}"
  tags = [
    "${data.null_data_source.tags.*.outputs}",
    {
      key                 = "Name"
      value               = "${local.environment_identifier}-${local.app_name}"
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

#Http file share
resource "aws_autoscaling_attachment" "http_fs_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  elb                    = "${module.http_fs_lb.environment_elb_id}"
}


#samba
resource "aws_autoscaling_attachment" "samba_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  elb                    = "${aws_elb.samba_lb.id}"
}
