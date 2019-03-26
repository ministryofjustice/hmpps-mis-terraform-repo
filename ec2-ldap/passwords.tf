###############################################
# LDAP - Admin Password
###############################################
resource "random_string" "password" {
  length  = 22
  special = true
}

# Add to SSM
resource "aws_ssm_parameter" "ssm_password" {
  name        = "${local.common_name}-ldap-admin-password"
  description = "${local.common_name}-ldap-admin-password"
  type        = "SecureString"
  value       = "${substr(sha256(bcrypt(random_string.password.result)),0,var.ad_password_length)}${random_string.special.result}"

  tags = "${merge(local.tags, map("Name", "${local.common_name}-ldap-admin-password"))}"

  lifecycle {
    ignore_changes = ["value"]
  }
}

# random strings for Password policy
resource "random_string" "special" {
  length           = 4
  special          = true
  min_upper        = 2
  min_special      = 2
  override_special = "!@$%&*()-_=+[]{}<>:?"
}

###############################################
# LDAP - Manager Password
###############################################
resource "random_string" "man_password" {
  length  = 22
  special = true
}

# Add to SSM
resource "aws_ssm_parameter" "manager_password" {
  name        = "${local.common_name}-ldap-manager-password"
  description = "${local.common_name}-ldap-manager-password"
  type        = "SecureString"
  value       = "${substr(sha256(bcrypt(random_string.man_password.result)),0,var.ad_password_length)}${random_string.man_special.result}"

  tags = "${merge(local.tags, map("Name", "${local.common_name}-ldap-manager-password"))}"

  lifecycle {
    ignore_changes = ["value"]
  }
}

# random strings for Password policy
resource "random_string" "man_special" {
  length           = 4
  special          = true
  min_upper        = 2
  min_special      = 2
  override_special = "!@$%&*()-_=+[]{}<>:?"
}
