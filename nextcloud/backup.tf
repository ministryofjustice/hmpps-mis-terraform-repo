#Backup Nextcloud EFS

resource "aws_backup_vault" "nextcloud_efs" {
  name = "${var.environment_name}-nextcloud-efs-bkup-pri-vlt"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-nextcloud-efs-bkup-pri-vlt"
    },
  )
}

resource "aws_backup_plan" "nextcloud_efs_backup_plan" {
  name = "${var.environment_name}-nextcloud-efs-bkup-pri-pln"

  rule {
    rule_name         = "MIS-EFS-backup"
    target_vault_name = aws_backup_vault.nextcloud_efs.name
    schedule          = var.ebs_backup["schedule"]

    lifecycle {
      cold_storage_after = var.ebs_backup["cold_storage_after"]
      delete_after       = var.ebs_backup["delete_after"]
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-nextcloud-efs-bkup-pri-pln"
    },
  )
}

resource "aws_backup_selection" "nextcloud_efs_backup_selection" {
  iam_role_arn = data.terraform_remote_state.iam.outputs.mis_ec2_backup_role_arn
  name         = "${var.environment_name}-nextcloud-efs-bkup-pri-sel"
  plan_id      = aws_backup_plan.nextcloud_efs_backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.snap_tag
    value = "${local.short_environment_identifier}-nextcloud-efs-share"
  }
}
