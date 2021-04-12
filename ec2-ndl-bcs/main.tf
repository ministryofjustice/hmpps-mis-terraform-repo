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
### Getting the s3 details
#-------------------------------------------------------------
data "terraform_remote_state" "s3bucket" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/s3buckets/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the IAM details
#-------------------------------------------------------------
data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/iam/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the security groups details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the sg details
#-------------------------------------------------------------
data "terraform_remote_state" "network-security-groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}


#-------------------------------------------------------------
### Getting the FSx Filesystem details (for security group)
#-------------------------------------------------------------
data "terraform_remote_state" "fsx-integration" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/fsx-integration/terraform.tfstate"
    region = var.region
  }
}


#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS MIS NART BCS Windows Server master *"]
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

  owners = ["895523100917"]
}

####################################################
# Locals
####################################################

locals {
  ami_id                       = data.aws_ami.amazon_ami.id
  account_id                   = data.terraform_remote_state.common.outputs.common_account_id
  vpc_id                       = data.terraform_remote_state.common.outputs.vpc_id
  cidr_block                   = data.terraform_remote_state.common.outputs.vpc_cidr_block
  allowed_cidr_block           = [data.terraform_remote_state.common.outputs.vpc_cidr_block]
  internal_domain              = data.terraform_remote_state.common.outputs.internal_domain
  private_zone_id              = data.terraform_remote_state.common.outputs.private_zone_id
  external_domain              = data.terraform_remote_state.common.outputs.external_domain
  public_zone_id               = data.terraform_remote_state.common.outputs.public_zone_id
  environment_identifier       = data.terraform_remote_state.common.outputs.environment_identifier
  short_environment_identifier = data.terraform_remote_state.common.outputs.short_environment_identifier
  region                       = var.region
  app_name                     = data.terraform_remote_state.common.outputs.mis_app_name
  environment                  = data.terraform_remote_state.common.outputs.environment
  tags                         = data.terraform_remote_state.common.outputs.common_tags
  private_subnet_map           = data.terraform_remote_state.common.outputs.private_subnet_map
  s3bucket                     = data.terraform_remote_state.s3bucket.outputs.s3bucket
  app_hostnames                = data.terraform_remote_state.common.outputs.app_hostnames

  public_cidr_block  = [data.terraform_remote_state.common.outputs.db_cidr_block]
  private_cidr_block = [data.terraform_remote_state.common.outputs.private_cidr_block]
  db_cidr_block      = [data.terraform_remote_state.common.outputs.db_cidr_block]
  sg_map_ids         = data.terraform_remote_state.security-groups.outputs.sg_map_ids
  instance_profile   = data.terraform_remote_state.iam.outputs.iam_policy_int_app_instance_profile_name
  ssh_deployer_key   = data.terraform_remote_state.common.outputs.common_ssh_deployer_key
  nart_role          = "ndl-bcs-${data.terraform_remote_state.common.outputs.legacy_environment_name}"

  # Create a prefix that removes the final integer from the nart_role value
  nart_prefix        = substr(local.nart_role, 0, length(local.nart_role) - 1)
  sg_outbound_id     = data.terraform_remote_state.common.outputs.common_sg_outbound_id
  sg_bws_ldap        = data.terraform_remote_state.network-security-groups.outputs.sg_bws_ldap
  nextcloud_samba_sg = data.terraform_remote_state.network-security-groups.outputs.sg_mis_samba
  config_bucket      = data.terraform_remote_state.common.outputs.common_s3-config-bucket

  #FSx Filesytem integration via Security Group membership
  fsx_integration_security_group    = data.terraform_remote_state.fsx-integration.outputs.mis_fsx_integration_security_group

  bcs_disable_api_termination = var.bcs_disable_api_termination
  bcs_ebs_optimized           = var.bcs_ebs_optimized 
  bcs_hibernation             = var.bcs_hibernation
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

data "aws_ssm_parameter" "bosso_user" {
  name = "${local.environment_identifier}-reports-admin-user"
}

data "aws_ssm_parameter" "bosso_password" {
  name = "${local.environment_identifier}-reports-admin-password"
}

# data "aws_security_group" "mis_bfs_filesystem_security_group" {
#   name = "tf-eu-west-2-hmpps-delius-mis-dev-mis-fsx"
# }

####################################################
# instance 1
####################################################

data "template_file" "instance_userdata" {
  template = file("../userdata/userdata.txt")
  count    = var.bcs_server_count
  vars = {
    # Build the host name by
    host_name         = "${local.nart_prefix}${count.index + 1}"
    internal_domain   = local.internal_domain
    user              = data.aws_ssm_parameter.user.value
    password          = data.aws_ssm_parameter.password.value
    bosso_user        = data.aws_ssm_parameter.bosso_user.value
    bosso_password    = data.aws_ssm_parameter.bosso_password.value
    cloudwatch_config = "s3://${local.config_bucket}/config.json"
  }
}

# Iteratively create EC2 instances
resource "aws_instance" "bcs_server" {
  count         = var.bcs_server_count
  ami           = data.aws_ami.amazon_ami.id
  instance_type = var.bcs_instance_type

  # element() function wraps if index > list count, so we get an even distribution across AZ subnets
  subnet_id                   = element(values(local.private_subnet_map), count.index)
  iam_instance_profile        = local.instance_profile
  associate_public_ip_address = false
  vpc_security_group_ids = [
    local.sg_map_ids["sg_mis_app_in"],
    local.sg_map_ids["sg_mis_common"],
    local.sg_outbound_id,
    local.sg_map_ids["sg_delius_db_out"],
    local.sg_bws_ldap,
    local.nextcloud_samba_sg,
    local.fsx_integration_security_group
  ]
  key_name = local.ssh_deployer_key

  volume_tags = merge(
    {
      "Name" = "${local.environment_identifier}-${local.app_name}-${local.nart_prefix}${count.index + 1}"
    },
    {
      "${var.snap_tag}" = 1
    },
  )

  tags = merge(
    local.tags,
    {
      "Name" = "${local.environment_identifier}-${local.app_name}-${local.nart_prefix}${count.index + 1}"
    },
    {
      "CreateSnapshot" = 0
    },
  )

  monitoring = true
  user_data  = element(data.template_file.instance_userdata.*.rendered, count.index)

  root_block_device {
    volume_size = var.bcs_root_size
  }

  disable_api_termination = local.bcs_disable_api_termination
  ebs_optimized           = local.bcs_ebs_optimized 
  hibernation             = local.bcs_hibernation

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_route53_record" "bcs_dns" {
  count   = var.bcs_server_count
  zone_id = local.private_zone_id
  name    = "${local.nart_prefix}${count.index + 1}.${local.internal_domain}"
  type    = "A"
  ttl     = "300"

  records = [element(aws_instance.bcs_server.*.private_ip, count.index)]
}

resource "aws_route53_record" "bcs_dns_ext" {
  count   = var.bcs_server_count
  zone_id = local.public_zone_id
  name    = "${local.nart_prefix}${count.index + 1}.${local.external_domain}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.bcs_server.*.private_ip, count.index)]
}
