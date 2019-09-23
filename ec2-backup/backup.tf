resource "aws_backup_vault" "mis_ec2_backup_vault" {
  name = "${var.environment_name}-mis-ec2-bkup-pri-vlt"
  tags = "${merge(local.tags, map("Name", "${var.environment_name}-mis-ec2-bkup-pri-vlt"))}"
}

resource "aws_backup_plan" "mis_ec2_backup_plan" {
  name = "${var.environment_name}-mis-ec2-bkup-pri-pln"

  rule {
    rule_name         = "MIS EC2 instance volume backup"
    target_vault_name = "${aws_backup_vault.mis_ec2_backup_vault.name}"
    schedule          = "${var.ebs_backup["schedule"]}"

    lifecycle = {
      cold_storage_after = "${var.ebs_backup["cold_storage_after"]}"
      delete_after       = "${var.ebs_backup["delete_after"]}"
    }
  }

  tags = "${merge(local.tags, map("Name", "${var.environment_name}-mis-ec2-bkup-pri-pln"))}"
}

resource "aws_backup_selection" "mis_ec2_backup_selection" {
  iam_role_arn = "${aws_iam_role.mis_ec2_backup_role.arn}"
  name         = "${var.environment_name}-mis-ec2-bkup-pri-sel"
  plan_id      = "${aws_backup_plan.mis_ec2_backup_plan.id}"

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Name"
    value = "tf-eu-west-2-hmpps-delius-pre-prod-mis-ndl-bfs-501"
  }
}
