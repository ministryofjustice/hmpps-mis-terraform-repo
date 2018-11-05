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
    key    = "${var.environment_type}/security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------

data "aws_ami" "centos_oracle_db" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Delius-Core OracleDB master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

####################################################
# Locals
####################################################

locals {
  ami_id                       = "${data.aws_ami.centos_oracle_db.id}"
  account_id                   = "${data.terraform_remote_state.common.common_account_id}"
  vpc_id                       = "${data.terraform_remote_state.common.vpc_id}"
  cidr_block                   = "${data.terraform_remote_state.common.vpc_cidr_block}"
  allowed_cidr_block           = ["${data.terraform_remote_state.common.vpc_cidr_block}"]
  internal_domain              = "${data.terraform_remote_state.common.internal_domain}"
  private_zone_id              = "${data.terraform_remote_state.common.private_zone_id}"
  external_domain              = "${data.terraform_remote_state.common.external_domain}"
  public_zone_id               = "${data.terraform_remote_state.common.public_zone_id}"
  environment_identifier       = "${data.terraform_remote_state.common.environment_identifier}"
  short_environment_identifier = "${data.terraform_remote_state.common.short_environment_identifier}"
  region                       = "${var.region}"
  app_name                     = "${data.terraform_remote_state.common.mis_app_name}"
  environment                  = "${data.terraform_remote_state.common.environment}"
  tags                         = "${data.terraform_remote_state.common.common_tags}"
  private_subnet_map           = "${data.terraform_remote_state.common.private_subnet_map}"
  s3bucket                     = "${data.terraform_remote_state.s3bucket.s3bucket}"
  app_hostnames                = "${data.terraform_remote_state.common.app_hostnames}"

  public_cidr_block     = ["${data.terraform_remote_state.common.db_cidr_block}"]
  private_cidr_block    = ["${data.terraform_remote_state.common.private_cidr_block}"]
  db_cidr_block         = ["${data.terraform_remote_state.common.db_cidr_block}"]
  db_subnet_ids         = ["${data.terraform_remote_state.common.db_subnet_ids}"]
  sg_map_ids            = "${data.terraform_remote_state.common.sg_map_ids}"
  instance_profile      = "${data.terraform_remote_state.iam.iam_policy_int_app_instance_profile_name}"
  ssh_deployer_key      = "${data.terraform_remote_state.common.common_ssh_deployer_key}"
  availability_zone_map = "${data.terraform_remote_state.common.availability_zone_map}"
  nart_role             = "ndl-bws"
  sg_outbound_id        = "${data.terraform_remote_state.common.common_sg_outbound_id}"
}

module "kms_key_db" {
  source   = "../modules/keys/encryption_key"
  key_name = "${local.environment}-db"
  tags     = "${merge(local.tags, map("Name", "${local.environment}-db"))}"
}

output "kms_arn_db" {
  value = "${module.kms_key_db.kms_arn}"
}

output "kms_key_id_db" {
  value = "${module.kms_key_db.key_id}"
}


module "ndl_ddb" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//oracle-database"
  server_name = "ndl-ddb-poc"

  ami_id               = "${data.aws_ami.centos_oracle_db.id}"
  instance_type        = "${var.instance_type}"
  db_subnet            = "${local.db_subnet_ids[0]}"
  key_name             = "${local.ssh_deployer_key}"
  iam_instance_profile = "${local.instance_profile}"

  security_group_ids = [
    "${local.sg_map_ids["sg_mis_app_in"]}",
    "${local.sg_map_ids["sg_mis_common"]}",
    "${local.sg_outbound_id}",
  ]

  tags                         = "${local.tags}"
  environment_name             = "${local.environment}"
  bastion_inventory            = "${var.bastion_inventory}"
  environment_identifier       = "${local.environment_identifier}"
  short_environment_identifier = "${local.short_environment_identifier}"

  environment_type = "${var.environment_type}"
  region           = "${var.region}"

  kms_key_id      = "${module.kms_key_db.kms_arn}"
  public_zone_id  = "${local.public_zone_id}"
  private_zone_id = "${local.private_zone_id}"
  private_domain  = "${local.internal_domain}"
  vpc_account_id  = "${local.vpc_id}"
}

output "public_fqdn_ndl_ddb" {
  value = "${module.ndl_ddb.public_fqdn}"
}

output "internal_fqdn_ndl_ddb" {
  value = "${module.ndl_ddb.internal_fqdn}"
}

output "private_ip_ndl_ddb" {
  value = "${module.ndl_ddb.private_ip}"
}
