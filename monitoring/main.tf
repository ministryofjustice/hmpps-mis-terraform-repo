terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.17"
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
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting bws instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bws" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-bws/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting dis instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-dis" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-dis/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting bps instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bps" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-bps/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting bfs instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bfs" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-bfs/terraform.tfstate"
    region = "${var.region}"
  }
}


#-------------------------------------------------------------
### Getting bcs instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bcs" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "${var.environment_type}/ec2-ndl-bcs/terraform.tfstate"
    region = "${var.region}"
  }
}



locals {
  environment_name             = "${var.environment_type}"
  environment_identifier       = "${data.terraform_remote_state.common.short_environment_identifier}"
  mis_app_name                 = "${data.terraform_remote_state.common.mis_app_name}"
  bws_lb_name                  = "${data.terraform_remote_state.ec2-ndl-bws.bws_elb_name}"
}
