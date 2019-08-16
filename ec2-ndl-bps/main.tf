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
    values = ["HMPPS MIS NART BFS Windows Server master *"]
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

  public_cidr_block  = ["${data.terraform_remote_state.common.db_cidr_block}"]
  private_cidr_block = ["${data.terraform_remote_state.common.private_cidr_block}"]
  db_cidr_block      = ["${data.terraform_remote_state.common.db_cidr_block}"]
  sg_map_ids         = "${data.terraform_remote_state.security-groups.sg_map_ids}"
  instance_profile   = "${data.terraform_remote_state.iam.iam_policy_int_app_instance_profile_name}"
  ssh_deployer_key   = "${data.terraform_remote_state.common.common_ssh_deployer_key}"
  nart_role          = "ndl-bps-${data.terraform_remote_state.common.legacy_environment_name}"
  # Create a prefix that removes the final integer from the nart_role value
  nart_prefix = "${ substr(local.nart_role, 0, length(local.nart_role)-1) }"
  sg_outbound_id     = "${data.terraform_remote_state.common.common_sg_outbound_id}" 
}

#-------------------------------------------------------------
## Getting the admin username and password
#-------------------------------------------------------------
data "aws_ssm_parameter" "user" {
  name = "${local.environment_identifier}-${local.app_name}-admin-user"
}

data "aws_ssm_parameter" "password" {
  name = "${local.environment_identifier}-${local.app_name}-admin-password"
}

####################################################
# instance 1
####################################################

data "template_file" "instance_userdata" {
  count = "${var.bps_server_count}"
  template = "${file("../userdata/userdata.txt")}"

  vars {
    host_name       = "${local.nart_prefix}${count.index + 1}"
    internal_domain = "${local.internal_domain}"
    user            = "${data.aws_ssm_parameter.user.value}"
    password        = "${data.aws_ssm_parameter.password.value}"
  }
}

# Iteratively create EC2 instances
resource "aws_instance" "bps_server" {
  count                       = "${var.bps_server_count}"
  ami                         = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${var.bps_instance_type}"
  # element() function wraps if index > list count, so we get an even distribution across AZ subnets
  subnet_id                   = "${element(values(local.private_subnet_map), count.index)}"
  iam_instance_profile        = "${local.instance_profile}"
  associate_public_ip_address = false
  vpc_security_group_ids      = [
    "${local.sg_map_ids["sg_mis_app_in"]}",
    "${local.sg_map_ids["sg_mis_common"]}",
    "${local.sg_outbound_id}",
    "${local.sg_map_ids["sg_delius_db_out"]}",
  ]
  key_name                    = "${local.ssh_deployer_key}"

  tags = "${merge(
    local.tags,
    map("Name", "${local.environment_identifier}-${local.app_name}-${local.nart_prefix}${count.index + 1}"),
    map("CreateSnapshot", false)
  )}"

  monitoring = true
  user_data  = "${element(data.template_file.instance_userdata.*.rendered, count.index)}"

  root_block_device {
    volume_size = "${var.bps_root_size}"
  }

  lifecycle {
    ignore_changes = [
      "ami",
      "user_data"
    ]
  }
}

resource "aws_route53_record" "bps_dns" {
  count = "${var.bps_server_count}"
  zone_id = "${local.private_zone_id}"
  name    = "${local.nart_prefix}${count.index + 1}.${local.internal_domain}"
  type    = "A"
  ttl     = "300"

  records = ["${element(aws_instance.bps_server.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "bps_dns_ext" {
  count = "${var.bps_server_count}"
  zone_id = "${local.public_zone_id}"
  name    = "${local.nart_prefix}${count.index + 1}.${local.external_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.bps_server.*.private_ip, count.index)}"]
}
