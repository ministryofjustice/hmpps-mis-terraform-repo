# SSM Parameters for cross-account sync
resource "aws_ssm_parameter" "cross_account_sync_id" {
  name  = "dfi-cross-account-sync-id"
  type  = "String"
  value = "PLACEHOLDER" # Update this manually after creation

  description = "AWS Account ID for DFI cross-account sync"

  tags = merge(
    local.tags,
    {
      "Name"        = "dfi-cross-account-sync"
      "Environment" = var.environment_name
    }
  )

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "sync_user" {
  name  = "modernisation-platform-oidc-cicd"
  type  = "String"
  value = "modernisation-platform-oidc-cicd"

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
