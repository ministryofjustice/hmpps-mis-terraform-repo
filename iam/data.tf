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
### Getting the s3bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3buckets" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/s3buckets/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the oracledb backup s3 bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3-oracledb-backups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "s3/oracledb-backups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the ssm docs s3 bucket
#-------------------------------------------------------------
data "terraform_remote_state" "ci_common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-pipelines/components/common/terraform.tfstate"
    region = var.region
  }
}
