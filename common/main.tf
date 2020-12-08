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
### Getting current
#-------------------------------------------------------------
data "aws_region" "current" {
}

#-------------------------------------------------------------
### Getting the vpc details
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

####################################################
# Locals
####################################################

locals {
  vpc_id                       = data.terraform_remote_state.vpc.outputs.vpc_id
  cidr_block                   = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  allowed_cidr_block           = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  bastion_cidr                 = data.terraform_remote_state.vpc.outputs.bastion_vpc_public_cidr
  internal_domain              = data.terraform_remote_state.vpc.outputs.private_zone_name
  private_zone_id              = data.terraform_remote_state.vpc.outputs.private_zone_id
  external_domain              = data.terraform_remote_state.vpc.outputs.public_zone_name
  public_zone_id               = data.terraform_remote_state.vpc.outputs.public_zone_id
  common_name                  = "${var.environment_identifier}-${var.mis_app_name}"
  lb_account_id                = var.lb_account_id
  region                       = var.region
  role_arn                     = var.role_arn
  environment_identifier       = var.environment_identifier
  short_environment_identifier = var.short_environment_identifier
  remote_state_bucket_name     = var.remote_state_bucket_name
  s3_lb_policy_file            = "../policies/s3_alb_policy.json"
  environment                  = var.environment_type
  legacy_environment_name      = var.legacy_environment_name
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "sub-project" = var.mis_app_name
    },
    {
      "legacy_environment_name" = var.legacy_environment_name
    },
    {
      "source-hash" = "ignored"
    },
    {
      "source-code" = "hmpps-mis-terraform-repo"
    }
  )

  ssh_deployer_key = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  password_length  = var.password_length

  app_hostnames = {
    internal = "${var.mis_app_name}-int"
    external = var.mis_app_name
  }

  private_subnet_map = {
    az1 = data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1
    az2 = data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2
    az3 = data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3
  }

  public_cidr_block = [
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3-cidr_block,
  ]

  private_cidr_block = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3-cidr_block,
  ]

  db_cidr_block = [
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az1-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az2-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az3-cidr_block,
  ]

  db_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az3,
  ]
}

####################################################
# Common
####################################################
module "common" {
  source                       = "../modules/common"
  cidr_block                   = local.cidr_block
  common_name                  = local.common_name
  environment                  = local.environment
  environment_identifier       = local.environment_identifier
  internal_domain              = local.internal_domain
  lb_account_id                = local.lb_account_id
  private_zone_id              = local.private_zone_id
  s3_lb_policy_file            = local.s3_lb_policy_file
  short_environment_identifier = local.short_environment_identifier
  tags                         = local.tags
  vpc_id                       = local.vpc_id
  region                       = local.region
  password_length              = local.password_length
}
