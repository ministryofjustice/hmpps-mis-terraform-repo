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
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS MIS NART Windows Server master *"]
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
    name   = "root-device-type"
    values = ["ebs"]
  }
}

####################################################
# Locals
####################################################

locals {
  ami_id                       = "${data.aws_ami.amazon_ami.id}"
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
  sg_map_ids            = "${data.terraform_remote_state.common.sg_map_ids}"
  instance_profile      = "${data.terraform_remote_state.iam.iam_policy_int_app_instance_profile_name}"
  ssh_deployer_key      = "${data.terraform_remote_state.common.common_ssh_deployer_key}"
  availability_zone_map = "${data.terraform_remote_state.common.availability_zone_map}"
  nart_role             = "ndl-bws"
  sg_outbound_id        = "${data.terraform_remote_state.common.common_sg_outbound_id}"
}

####################################################
# instance 1
####################################################

#-------------------------------------------------------------
### Create instance - NDL-BWS-001 
#-------------------------------------------------------------
module "create-ec2-instance" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ec2"
  app_name                    = "${local.environment_identifier}-${local.app_name}-${local.nart_role}-001"
  ami_id                      = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${local.private_subnet_map["az1"]}"
  iam_instance_profile        = "${local.instance_profile}"
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = ""
  CreateSnapshot              = false
  tags                        = "${local.tags}"
  key_name                    = "${local.ssh_deployer_key}"
  root_device_size            = "60"

  vpc_security_group_ids = [
    "${local.sg_map_ids["sg_mis_app_in"]}",
    "${local.sg_map_ids["sg_mis_common"]}",
    "${local.sg_outbound_id}",
  ]
}

#-------------------------------------------------------------
# Create ebs volume
#-------------------------------------------------------------
module "ebs-ec2-instance" {
  source            = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ebs//ebs_volume"
  availability_zone = "${local.availability_zone_map["az1"]}"
  volume_size       = "50"
  encrypted         = true
  app_name          = "${local.environment_identifier}-${local.app_name}-${local.nart_role}-001"
  tags              = "${local.tags}"
  CreateSnapshot    = false
}

module "ebs-attach-ec2-instance" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ebs//ebs_attachment"
  device_name = "/dev/sdb"
  instance_id = "${module.create-ec2-instance.instance_id}"
  volume_id   = "${module.ebs-ec2-instance.id}"
}

#-------------------------------------------------------------
# Create route53 entry for instance 1
#-------------------------------------------------------------

resource "aws_route53_record" "instance" {
  zone_id = "${local.private_zone_id}"
  name    = "${local.nart_role}-001.${local.internal_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${module.create-ec2-instance.private_ip}"]
}

####################################################
# instance 2
####################################################

#-------------------------------------------------------------
### Create instance - NDL-BWS-002
#-------------------------------------------------------------
module "create-ec2-instance1" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ec2"
  app_name                    = "${local.environment_identifier}-${local.app_name}-${local.nart_role}-002"
  ami_id                      = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${local.private_subnet_map["az2"]}"
  iam_instance_profile        = "${local.instance_profile}"
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = ""
  CreateSnapshot              = false
  tags                        = "${local.tags}"
  key_name                    = "${local.ssh_deployer_key}"
  root_device_size            = "60"

  vpc_security_group_ids = [
    "${local.sg_map_ids["sg_mis_app_in"]}",
    "${local.sg_map_ids["sg_mis_common"]}",
    "${local.sg_outbound_id}",
  ]
}

#-------------------------------------------------------------
# Create ebs volume
#-------------------------------------------------------------
module "ebs-ec2-instance1" {
  source            = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ebs//ebs_volume"
  availability_zone = "${local.availability_zone_map["az2"]}"
  volume_size       = "50"
  encrypted         = true
  app_name          = "${local.environment_identifier}-${local.app_name}-${local.nart_role}-002"
  tags              = "${local.tags}"
  CreateSnapshot    = false
}

module "ebs-attach-ec2-instance1" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ebs//ebs_attachment"
  device_name = "/dev/sdb"
  instance_id = "${module.create-ec2-instance1.instance_id}"
  volume_id   = "${module.ebs-ec2-instance1.id}"
}

#-------------------------------------------------------------
# Create route53 entry for instance 1
#-------------------------------------------------------------

resource "aws_route53_record" "instance1" {
  zone_id = "${local.private_zone_id}"
  name    = "${local.nart_role}-002.${local.internal_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${module.create-ec2-instance1.private_ip}"]
}
