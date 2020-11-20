terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/common/terraform.tfstate"
    region = var.region
  }
}

locals {

  vpc_id                       = data.terraform_remote_state.common.outputs.vpc_id
  
  environment_identifier = data.terraform_remote_state.common.outputs.environment_identifier
  environment_name       = var.environment_name
  common_name            = "${local.environment_identifier}-${var.mis_app_name}"
  
  tags = data.terraform_remote_state.common.outputs.common_tags

  bfs_filesystem_name    = "mis-bfs"


  security_group_name = "${local.common_name}-fsx-integration"

}