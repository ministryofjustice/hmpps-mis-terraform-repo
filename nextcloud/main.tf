terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/common/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the s3 details
#-------------------------------------------------------------
data "terraform_remote_state" "s3bucket" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/s3buckets/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the IAM details
#-------------------------------------------------------------
data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/iam/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the security groups details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the VPC details
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the nextloud details
#-------------------------------------------------------------
data "terraform_remote_state" "nextcloud" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/nextcloud/terraform.tfstate"
    region = var.region
  }
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
### Getting the ldap elb details
#-------------------------------------------------------------
data "terraform_remote_state" "ldap_elb_name" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting ACM Cert
#-------------------------------------------------------------
data "aws_acm_certificate" "nextcloud_cert" {
  domain      = "*.${data.terraform_remote_state.common.outputs.external_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

#-------------------------------------------------------------
### Getting the PWM details
#-------------------------------------------------------------
#data "terraform_remote_state" "delius-core-pwm" {
#  backend = "s3"
#
#  config {
#    bucket = "${var.remote_state_bucket_name}"
#    key    = "delius-core/application/pwm/terraform.tfstate"
#    region = "${var.region}"
#  }
#}

#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Nextcloud master *"]
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
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["895523100917"]
}

locals {
  environment_name             = data.terraform_remote_state.vpc.outputs.environment_name
  internal_domain              = data.terraform_remote_state.vpc.outputs.private_zone_name
  private_zone_id              = data.terraform_remote_state.vpc.outputs.private_zone_id
  external_domain              = data.terraform_remote_state.vpc.outputs.public_zone_name
  region                       = var.region
  ssh_deployer_key             = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  app_name                     = "nextcloud"
  mis_app_name                 = data.terraform_remote_state.common.outputs.mis_app_name
  bastion_inventory            = var.bastion_inventory
  environment_identifier       = data.terraform_remote_state.common.outputs.environment_identifier
  short_environment_identifier = data.terraform_remote_state.common.outputs.short_environment_identifier
  ec2_policy_file              = "ec2_policy.json"
  ec2_role_policy_file         = "policies/ec2.json"
  sg_bastion_in                = data.terraform_remote_state.security-groups.outputs.sg_ssh_bastion_in_id
  sg_https_out                 = data.terraform_remote_state.security-groups.outputs.sg_https_out
  s3bucket                     = data.terraform_remote_state.s3bucket.outputs.s3bucket
  logs_bucket                  = data.terraform_remote_state.common.outputs.common_s3_lb_logs_bucket
  certificate_arn              = data.aws_acm_certificate.nextcloud_cert.arn
  sg_mis_app_in                = data.terraform_remote_state.security-groups.outputs.sg_mis_app_in
  public_zone_id               = data.terraform_remote_state.vpc.outputs.public_zone_id
  public_subnet_ids            = flatten([data.terraform_remote_state.common.outputs.public_subnet_ids])
  private_subnet_ids           = data.terraform_remote_state.common.outputs.private_subnet_ids
  ldap_elb_name                = data.terraform_remote_state.ldap_elb_name.outputs.private_fqdn_ldap_elb
  ldap_port                    = data.terraform_remote_state.ldap_elb_name.outputs.ldap_port
  nextcloud_admin_user         = "${local.environment_name}-${local.mis_app_name}-nextcloud"
  nextcloud_admin_pass_param   = aws_ssm_parameter.nextcloud_ssm_password.id
  nextcloud_db_user_pass_param = aws_ssm_parameter.nextcloud_db_password.id
  efs_security_groups          = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_efs_in
  efs_dns_name                 = module.efs_share.efs_dns_name
  nextcloud_db_user            = "${local.mis_app_name}${local.app_name}"
  nextcloud_db_sg              = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_db
  nextcloud_samba_sg           = data.terraform_remote_state.security-groups.outputs.sg_mis_samba
  db_dns_name                  = aws_route53_record.mariadb_dns_entry.fqdn
  ldap_bind_user               = data.terraform_remote_state.ldap_elb_name.outputs.ldap_bind_user
  backup_bucket                = data.terraform_remote_state.s3bucket.outputs.nextcloud_s3_bucket
  redis_address                = aws_route53_record.nextcloud_cache_dns.fqdn
  installer_user               = "installer_user"
  config_passw                 = "${local.environment_identifier}-${local.app_name}-config-password"
  nextcloud_s3_bucket_arn      = data.terraform_remote_state.s3bucket.outputs.nextcloud_s3_bucket_arn
  public_cidr_block            = data.terraform_remote_state.common.outputs.public_cidr_block
  cidr_block_a_subnet          = replace(element(local.public_cidr_block, 0), "/", "\\/")
  cidr_block_b_subnet          = replace(element(local.public_cidr_block, 1), "/", "\\/")
  cidr_block_c_subnet          = replace(element(local.public_cidr_block, 2), "/", "\\/")
  #  pwm_url                     = "${data.terraform_remote_state.delius-core-pwm.public_fqdn_pwm}"
  pwm_url                      = "password-reset.${data.terraform_remote_state.vpc.outputs.public_zone_name}"
  strategic_pwm_url            = "password-reset.${data.terraform_remote_state.vpc.outputs.strategic_public_zone_name}"
  sg_smtp_ses                  = data.terraform_remote_state.security-groups.outputs.sg_smtp_ses
  lb_name                      = "${local.short_environment_identifier}-${local.app_name}"
  internal_lb_security_groups  = flatten([data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_lb])
  tags                         = data.terraform_remote_state.common.outputs.common_tags
  wmt_bucket_name_prod         = "cloud-platform-9e0eba6eec2e9201f579ec962c359771"
  wmt_bucket_name_pre_prod     = "cloud-platform-b104c43876f0c93d0073505543fa70d1"
}
