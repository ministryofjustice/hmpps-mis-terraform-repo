###############################################
# PASSWORD
###############################################
locals {
  common_name = "${var.environment_identifier}"
  tags        = "${var.tags}"
}

resource "random_string" "password" {
  length  = 20
  special = true
}

# Add to SSM
resource "aws_ssm_parameter" "param" {
  name        = "${local.common_name}"
  description = "${local.common_name}"
  type        = "SecureString"
  value       = "${sha256(bcrypt(random_string.password.result))}"

  tags = "${merge(local.tags, map("Name", "${local.common_name}"))}"

  lifecycle {
    ignore_changes = ["value"]
  }
}
