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
    key    = "${var.environment_type}/security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base CentOS master *"]
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

  owners = ["${data.terraform_remote_state.common.common_account_id}", "895523100917"] # AWS
}

####################################################
# Locals
####################################################

locals {
  region                       = "${var.region}"
  account_id                   = "${data.terraform_remote_state.common.common_account_id}"
  app_name                     = "${data.terraform_remote_state.common.mis_app_name}"
  environment_identifier       = "${data.terraform_remote_state.common.environment_identifier}"
  short_environment_identifier = "${data.terraform_remote_state.common.short_environment_identifier}"
  common_name                  = "${data.terraform_remote_state.common.environment_identifier}-${data.terraform_remote_state.common.mis_app_name}"
  tags                         = "${data.terraform_remote_state.common.common_tags}"
  vpc_id                       = "${data.terraform_remote_state.common.vpc_id}"
  internal_domain              = "${data.terraform_remote_state.common.internal_domain}"
  private_zone_id              = "${data.terraform_remote_state.common.private_zone_id}"
  environment                  = "${data.terraform_remote_state.common.environment}"
  sg_map_ids                   = "${data.terraform_remote_state.common.sg_map_ids}"
  instance_profile             = "${data.terraform_remote_state.iam.iam_policy_int_ldap_instance_profile_name}"
  ssh_deployer_key             = "${data.terraform_remote_state.common.common_ssh_deployer_key}"
  availability_zone_map        = "${data.terraform_remote_state.common.availability_zone_map}"
  nart_role                    = "ldap"
  sg_outbound_id               = "${data.terraform_remote_state.common.common_sg_outbound_id}"
  private_subnet_map           = "${data.terraform_remote_state.common.private_subnet_map}"
  ldap_primary                 = "ldap-primary"
  ldap_replica                 = "ldap-replica"
}

###############################################
# LDAP - Admin Password
###############################################
resource "random_string" "password" {
  length  = 22
  special = true
}

# Add to SSM
resource "aws_ssm_parameter" "ssm_password" {
  name        = "${local.common_name}-ldap-admin-password"
  description = "${local.common_name}-ldap-admin-password"
  type        = "SecureString"
  value       = "${substr(sha256(bcrypt(random_string.password.result)),0,var.ad_password_length)}${random_string.special.result}"

  tags = "${merge(local.tags, map("Name", "${local.common_name}-ldap-admin-password"))}"

  lifecycle {
    ignore_changes = ["value"]
  }
}

# random strings for Password policy
resource "random_string" "special" {
  length           = 4
  special          = true
  min_upper        = 2
  min_special      = 2
  override_special = "!@$%&*()-_=+[]{}<>:?"
}

###############################################
# LDAP - Manager Password
###############################################
resource "random_string" "man_password" {
  length  = 22
  special = true
}

# Add to SSM
resource "aws_ssm_parameter" "manager_password" {
  name        = "${local.common_name}-ldap-manager-password"
  description = "${local.common_name}-ldap-manager-password"
  type        = "SecureString"
  value       = "${substr(sha256(bcrypt(random_string.man_password.result)),0,var.ad_password_length)}${random_string.man_special.result}"

  tags = "${merge(local.tags, map("Name", "${local.common_name}-ldap-manager-password"))}"

  lifecycle {
    ignore_changes = ["value"]
  }
}

# random strings for Password policy
resource "random_string" "man_special" {
  length           = 4
  special          = true
  min_upper        = 2
  min_special      = 2
  override_special = "!@$%&*()-_=+[]{}<>:?"
}
