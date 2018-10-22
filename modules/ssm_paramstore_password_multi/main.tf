###############################################
# PASSWORD
###############################################
locals {
  common_name = "${var.environment_identifier}"
  tags        = "${var.tags}"
  passwords   = ["${var.passwords}"]
}

resource "random_string" "passwords" {
  length  = 20
  special = true
  count   = "${length(local.passwords)}"
}

resource "aws_ssm_parameter" "param" {
  name        = "${local.common_name}_${element(local.passwords, count.index)}"
  description = "${local.common_name}"
  type        = "SecureString"
  value       = "${sha256(bcrypt(element(random_string.passwords.*.result, count.index)))}"

  tags = "${merge(local.tags, map("Name", "${local.common_name}_${element(local.passwords, count.index)}"))}"

  lifecycle {
    ignore_changes = ["value"]
  }

  count = "${length(local.passwords)}"
}
