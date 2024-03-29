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
### Getting the monitoring resources details
#-------------------------------------------------------------
data "terraform_remote_state" "monitoring" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/monitoring/terraform.tfstate"
    region = var.region
  }
}