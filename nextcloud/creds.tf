###############################################
# nextcloud db account
###############################################
resource "random_string" "nextcloud_db_password" {
  length  = 22
  special = true
}

# Add to SSM
resource "aws_ssm_parameter" "nextcloud_db_password" {
  name        = "${local.environment_identifier}-${local.app_name}-db-password"
  description = "${local.environment_identifier}-${local.app_name}-db-password"
  type        = "SecureString"
  value = "${substr(
    sha256(bcrypt(random_string.password.result)),
    0,
    var.password_length,
  )}${random_string.nextcloud_special.result}"

  tags = merge(
    var.tags,
    {
      "Name" = "${local.environment_identifier}-db-password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}

# Add to SSM
resource "aws_ssm_parameter" "nextcloud_db_user" {
  name        = "${local.environment_identifier}-${local.app_name}-db-user"
  description = "${local.environment_identifier}-${local.app_name}-db-user"
  type        = "String"
  value       = local.nextcloud_db_user
  tags = merge(
    var.tags,
    {
      "Name" = "${local.environment_identifier}-db-user"
    },
  )
}

# random strings for Password policy
resource "random_string" "nextcloud_special" {
  length           = 4
  special          = true
  min_upper        = 2
  min_special      = 2
  override_special = "!$%&*()-_=+[]{}<>"
}

###############################################
# nextcloud admin account
###############################################
resource "random_string" "password" {
  length  = 22
  special = true
}

# Add to SSM
resource "aws_ssm_parameter" "nextcloud_ssm_password" {
  name        = "${local.environment_identifier}-nextcloud-admin-password"
  description = "${local.environment_identifier}-nextcloud-admin-password"
  type        = "SecureString"
  value = "${substr(
    sha256(bcrypt(random_string.password.result)),
    0,
    var.password_length,
  )}${random_string.special.result}"

  tags = merge(
    var.tags,
    {
      "Name" = "${local.environment_identifier}-admin-password"
    },
  )

  lifecycle {
    ignore_changes = [value]
  }
}

# Add to SSM
resource "aws_ssm_parameter" "nextcloud_ssm_user" {
  name        = "${local.environment_identifier}-nextcloud-admin-user"
  description = "${local.environment_identifier}-nextcloud-admin-user"
  type        = "String"
  value       = local.nextcloud_admin_user
  tags = merge(
    var.tags,
    {
      "Name" = "${local.environment_identifier}-admin-user"
    },
  )
}

# random strings for Password policy
resource "random_string" "special" {
  length           = 4
  special          = true
  min_upper        = 2
  min_special      = 2
  override_special = "!@$%&*()-_=+[]{}<>:?"
}
