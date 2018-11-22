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
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base Docker Centos *"]
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
    name = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  app_name             = "smtp"
  ec2_policy_file      = "ec2_policy.json"
  ec2_role_policy_file = "policies/ec2.json"
}

data "template_file" "iam_policy_app" {
  template = "${file("${path.module}/${local.ec2_role_policy_file}")}"
}

module "iam_app_role" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//role"
  rolename   = "${data.terraform_remote_state.common.environment_identifier}-${local.app_name}-smtp"
  policyfile = "${local.ec2_policy_file}"
}

module "iam_instance_profile" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//instance_profile"
  role   = "${module.iam_app_role.iamrole_name}"
}

module "iam_app_policy" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//rolepolicy"
  policyfile = "${data.template_file.iam_policy_app.rendered}"
  rolename   = "${module.iam_app_role.iamrole_name}"
}

data "template_file" "postfix_user_data" {
  template = "${file("user_data/bootstrap.sh")}"

  vars {
    app_name              = "${local.app_name}"
    mail_hostname         = "${local.app_name}.${data.terraform_remote_state.common.external_domain}"
    private_domain        = "${data.terraform_remote_state.common.internal_domain}"
    env_identifier        = "${data.terraform_remote_state.common.environment_identifier}"
    short_env_identifier  = "${data.terraform_remote_state.common.short_environment_identifier}"
    account_id            = "${data.terraform_remote_state.common.common_account_id}"
    bastion_inventory     = "dev"
  }
}

#-------------------------------------------------------------
### Create instance
#-------------------------------------------------------------
module "create-ec2-instance" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ec2"
  app_name                    = "${data.terraform_remote_state.common.environment_identifier}-${local.app_name}"
  ami_id                      = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "t2.small"
  subnet_id                   = "${data.terraform_remote_state.common.private_subnet_map["az3"]}"
  iam_instance_profile        = "${module.iam_instance_profile.iam_instance_name}"
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = "${data.template_file.postfix_user_data.rendered}"
  CreateSnapshot              = true
  tags                        = "${data.terraform_remote_state.common.common_tags}"
  key_name                    = "${data.terraform_remote_state.common.common_ssh_deployer_key}"

  vpc_security_group_ids = [
    "${aws_security_group.mis_smtp_host.id}"
  ]
}