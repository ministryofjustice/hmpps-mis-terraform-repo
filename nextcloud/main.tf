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
### Getting the nextloud details
#-------------------------------------------------------------
data "terraform_remote_state" "nextcloud" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/nextcloud/terraform.tfstate"
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
data "aws_acm_certificate" "nextcloud_cert" {
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

locals {
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  internal_domain              = "${data.terraform_remote_state.vpc.private_zone_name}"
  private_zone_id              = "${data.terraform_remote_state.vpc.private_zone_id}"
  external_domain              = "${data.terraform_remote_state.vpc.public_zone_name}"
  region                       = "${var.region}"
  ssh_deployer_key             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  app_name                     = "nextcloud"
  mis_app_name                 = "${data.terraform_remote_state.common.mis_app_name}"
  bastion_inventory            = "${var.bastion_inventory}"
  environment_identifier       = "${data.terraform_remote_state.common.environment_identifier}"
  short_environment_identifier = "${data.terraform_remote_state.common.short_environment_identifier}"
  ec2_policy_file              = "ec2_policy.json"
  ec2_role_policy_file         = "policies/ec2.json"
  sg_bastion_in                = "${data.terraform_remote_state.security-groups.sg_ssh_bastion_in_id}"
  sg_https_out                 = "${data.terraform_remote_state.security-groups.sg_https_out}"
  s3bucket                     = "${data.terraform_remote_state.s3bucket.s3bucket}"
  logs_bucket                  = "${data.terraform_remote_state.common.common_s3_lb_logs_bucket}"
  certificate_arn              = "${data.aws_acm_certificate.nextcloud_cert.arn}"
  sg_mis_app_in                = "${data.terraform_remote_state.security-groups.sg_mis_app_in}"
  public_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
  public_subnet_ids            = ["${data.terraform_remote_state.common.public_subnet_ids}"]
  private_subnet_ids           = ["${data.terraform_remote_state.common.private_subnet_ids}"]
  tags                         = "${data.terraform_remote_state.vpc.tags}"
  ldap_elb_name                = "${data.terraform_remote_state.ldap_elb_name.private_fqdn_ldap_elb}"
  ldap_port                    = "${data.terraform_remote_state.ldap_elb_name.ldap_port}"
  nextcloud_admin_user         = "${local.environment_name}-${local.mis_app_name}-nextcloud"
  nextcloud_admin_pass_param   = "${aws_ssm_parameter.nextcloud_ssm_password.id}"
  nextcloud_db_user_pass_param = "${aws_ssm_parameter.nextcloud_db_password.id}"
  efs_security_groups          = ["${data.terraform_remote_state.security-groups.sg_mis_nextcloud_efs_in}",]
  efs_dns_name                 = "${module.efs_share.efs_dns_name}"
  nextcloud_db_user            = "${local.mis_app_name}${local.app_name}"
  nextcloud_db_sg              = ["${data.terraform_remote_state.security-groups.sg_mis_nextcloud_db}",]
  db_dns_name                  = "${aws_route53_record.mariadb_dns_entry.fqdn}"
  ldap_bind_user               = "${data.terraform_remote_state.ldap_elb_name.ldap_bind_user}"
}
