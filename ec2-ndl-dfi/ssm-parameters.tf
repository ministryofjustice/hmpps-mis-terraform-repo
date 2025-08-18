# SSM Parameters for cross-account sync
resource "aws_ssm_parameter" "cross_account_sync_id_development" {
  name  = "dfi-cross-account-sync-development"
  type  = "String"
  value = "PLACEHOLDER" # Update this manually after creation

  description = "AWS Account ID for DFI cross-account sync - Development environment"

  tags = merge(
    local.tags,
    {
      "Name"        = "dfi-cross-account-sync-development"
      "Environment" = "development"
    }
  )

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "cross_account_sync_id_preproduction" {
  name  = "dfi-cross-account-sync-preproduction"
  type  = "String"
  value = "PLACEHOLDER" # Update this manually after creation

  description = "AWS Account ID for DFI cross-account sync - Pre-production environment"

  tags = merge(
    local.tags,
    {
      "Name"        = "dfi-cross-account-sync-preproduction"
      "Environment" = "preproduction"
    }
  )

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "cross_account_sync_id_production" {
  name  = "dfi-cross-account-sync-production"
  type  = "String"
  value = "PLACEHOLDER" # Update this manually after creation

  description = "AWS Account ID for DFI cross-account sync - Production environment"

  tags = merge(
    local.tags,
    {
      "Name"        = "dfi-cross-account-sync-production"
      "Environment" = "production"
    }
  )

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "sync_user" {
  name  = "modernisation-platform-oidc-cicd"
  type  = "String"
  value = "PLACEHOLDER" # Update this manually after creation

  description = "Username for DFI cross-account sync operations"

  tags = merge(
    local.tags,
    {
      "Name" = "modernisation-platform-oidc-cicd"
    }
  )

  lifecycle {
    ignore_changes = [value]
  }
}
