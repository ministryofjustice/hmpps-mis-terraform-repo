terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

####################################################
# instance 1
####################################################

data "template_file" "instance_userdata" {
  template = file("../userdata/userdata.txt")
  count    = var.dfi_server_count
  vars = {
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
resource "aws_instance" "dfi_server" {
  count         = var.dfi_server_count
  ami           = data.aws_ami.amazon_ami.id
  instance_type = var.dfi_instance_type

  # element() function wraps if index > list count, so we get an even distribution across AZ subnets
  subnet_id                   = element(values(local.private_subnet_map), count.index)
  iam_instance_profile        = local.instance_profile
  associate_public_ip_address = false
  vpc_security_group_ids = [
    local.sg_map_ids["sg_mis_app_in"],
    local.sg_map_ids["sg_mis_common"],
    local.sg_outbound_id,
    local.sg_map_ids["sg_mis_db_in"],
    local.sg_map_ids["sg_delius_db_out"],
    local.sg_smtp_ses,
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
  local.overide_tags,
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
    volume_size = var.dfi_root_size
  }

  disable_api_termination = local.dfi_disable_api_termination
  ebs_optimized           = local.dfi_ebs_optimized
  hibernation             = local.dfi_hibernation

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_route53_record" "dfi_dns" {
  count   = var.dfi_server_count
  zone_id = local.private_zone_id
  name    = "${local.nart_prefix}${count.index + 1}.${local.internal_domain}"
  type    = "A"
  ttl     = "300"

  records = [element(aws_instance.dfi_server.*.private_ip, count.index)]
}

resource "aws_route53_record" "dfi_dns_ext" {
  count   = var.dfi_server_count
  zone_id = local.public_zone_id
  name    = "${local.nart_prefix}${count.index + 1}.${local.external_domain}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.dfi_server.*.private_ip, count.index)]
}
