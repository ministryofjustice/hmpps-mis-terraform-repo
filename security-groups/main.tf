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
### Getting the sg details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

####################################################
# Locals
####################################################

locals {
  vpc_id                  = "${data.terraform_remote_state.common.vpc_id}"
  cidr_block              = "${data.terraform_remote_state.common.vpc_cidr_block}"
  user_access_cidr_blocks = ["${var.user_access_cidr_blocks}"]
  bastion_cidr            = ["${data.terraform_remote_state.common.bastion_cidr}"]
  common_name             = "${data.terraform_remote_state.common.common_name}"
  region                  = "${data.terraform_remote_state.common.region}"
  app_name                = "${data.terraform_remote_state.common.mis_app_name}"
  environment_identifier  = "${data.terraform_remote_state.common.environment_identifier}"
  environment             = "${data.terraform_remote_state.common.environment}"
  tags                    = "${data.terraform_remote_state.common.common_tags}"
  public_cidr_block       = ["${data.terraform_remote_state.common.db_cidr_block}"]
  private_cidr_block      = ["${data.terraform_remote_state.common.private_cidr_block}"]
  db_cidr_block           = ["${data.terraform_remote_state.common.db_cidr_block}"]

  sg_map_ids = {
    sg_mis_db_in  = "${data.terraform_remote_state.security-groups.sg_mis_db_in}"
    sg_mis_common = "${data.terraform_remote_state.security-groups.sg_mis_common}"
    sg_mis_app_in = "${data.terraform_remote_state.security-groups.sg_mis_app_in}"
    sg_mis_app_lb = "${data.terraform_remote_state.security-groups.sg_mis_app_lb}"
    sg_ldap_lb    = "${data.terraform_remote_state.security-groups.sg_ldap_lb}"
    sg_ldap_inst  = "${data.terraform_remote_state.security-groups.sg_ldap_inst}"
    sg_ldap_proxy = "${data.terraform_remote_state.security-groups.sg_ldap_proxy}"
    sg_jumphost   = "${data.terraform_remote_state.security-groups.sg_jumphost}"
    sg_delius_db  = "${data.terraform_remote_state.security-groups.sg_mis_out_to_delius_db_id}"
  }
}

locals {
  sg_mis_common = "${local.sg_map_ids["sg_mis_common"]}"
  sg_jumphost   = "${local.sg_map_ids["sg_jumphost"]}"
  sg_mis_app_lb = "${local.sg_map_ids["sg_mis_app_lb"]}"
  sg_ldap_inst  = "${local.sg_map_ids["sg_ldap_inst"]}"
  sg_ldap_proxy = "${local.sg_map_ids["sg_ldap_proxy"]}"
  sg_ldap_lb    = "${local.sg_map_ids["sg_ldap_lb"]}"
  sg_mis_db_in  = "${local.sg_map_ids["sg_mis_db_in"]}"
  sg_mis_app_in = "${local.sg_map_ids["sg_mis_app_in"]}"
  sg_delius_db  = "${local.sg_map_ids["sg_delius_db"]}"
}
