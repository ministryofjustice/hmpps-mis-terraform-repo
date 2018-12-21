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
### Getting the s3bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3buckets" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/s3buckets/terraform.tfstate"
    region = "${var.region}"
  }
}

####################################################
# Locals
####################################################

locals {
  region           = "${var.region}"
  common_name      = "${data.terraform_remote_state.common.common_name}"
  tags             = "${data.terraform_remote_state.common.common_tags}"
  s3-config-bucket = "${data.terraform_remote_state.common.common_s3-config-bucket}"
  artefact-bucket  = "${data.terraform_remote_state.s3buckets.s3bucket}"
  runtime_role     = "${var.cross_account_iam_role}"
  account_id       = "${data.terraform_remote_state.common.common_account_id}"
}

####################################################
# IAM - Application Specific
####################################################
module "iam" {
  source                   = "../modules/iam"
  common_name              = "${local.common_name}-infra"
  tags                     = "${local.tags}"
  ec2_policy_file          = "ec2_policy.json"
  ec2_internal_policy_file = "${file("../policies/ec2_internal_policy.json")}"
  s3-config-bucket         = "${local.s3-config-bucket}"
  artefact-bucket          = "${local.artefact-bucket}"
  runtime_role             = "${local.runtime_role}"
  region                   = "${local.region}"
  account_id               = "${local.account_id}"
}

####################################################
# IAM - Application Specific
####################################################
module "jumphost" {
  source                   = "../modules/iam"
  common_name              = "${local.common_name}-jumphost"
  tags                     = "${local.tags}"
  ec2_policy_file          = "ec2_policy.json"
  ec2_internal_policy_file = "${file("../policies/ec2_jumphost_policy.json")}"
  s3-config-bucket         = "${local.s3-config-bucket}"
  artefact-bucket          = "${local.artefact-bucket}"
  region                   = "${local.region}"
  account_id               = "${local.account_id}"
}

####################################################
# IAM - Application Specific LDAP
####################################################
module "ldap" {
  source                   = "../modules/iam"
  common_name              = "${local.common_name}-ldap"
  tags                     = "${local.tags}"
  ec2_policy_file          = "ec2_policy.json"
  ec2_internal_policy_file = "${file("../policies/ec2_ldap_policy.json")}"
  s3-config-bucket         = "${local.s3-config-bucket}"
  artefact-bucket          = "${local.artefact-bucket}"
  region                   = "${local.region}"
  account_id               = "${local.account_id}"
}
