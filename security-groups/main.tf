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

####################################################
# Locals
####################################################

locals {
  vpc_id                 = "${data.terraform_remote_state.common.vpc_id}"
  cidr_block             = "${data.terraform_remote_state.common.vpc_cidr_block}"
  allowed_cidr_block     = ["${var.allowed_cidr_block}"]
  common_name            = "${data.terraform_remote_state.common.environment_identifier}"
  region                 = "${data.terraform_remote_state.common.region}"
  app_name               = "${data.terraform_remote_state.common.mis_app_name}"
  environment_identifier = "${data.terraform_remote_state.common.environment_identifier}"
  environment            = "${data.terraform_remote_state.common.environment}"
  tags                   = "${data.terraform_remote_state.common.common_tags}"
  public_cidr_block      = ["${data.terraform_remote_state.common.db_cidr_block}"]
  private_cidr_block     = ["${data.terraform_remote_state.common.private_cidr_block}"]
  db_cidr_block          = ["${data.terraform_remote_state.common.db_cidr_block}"]
  sg_map_ids             = "${data.terraform_remote_state.common.sg_map_ids}"
}

####################################################
# Security Groups - Application Specific
####################################################
module "security_groups" {
  source                 = "../modules/security-groups"
  app_name               = "${local.app_name}"
  allowed_cidr_block     = ["${local.allowed_cidr_block}"]
  common_name            = "${local.common_name}"
  environment_identifier = "${local.environment_identifier}"
  region                 = "${local.region}"
  tags                   = "${local.tags}"
  vpc_id                 = "${local.vpc_id}"
  public_cidr_block      = ["${local.public_cidr_block}"]
  private_cidr_block     = ["${local.private_cidr_block}"]
  db_cidr_block          = ["${local.db_cidr_block}"]
  sg_map_ids             = "${local.sg_map_ids}"
}
