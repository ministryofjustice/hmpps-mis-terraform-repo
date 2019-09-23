data "template_file" "backup_assume_role_template" {
  template = "${file("../policies/backup_assume_role.tpl")}"
  vars     = {}
}
resource "aws_iam_role" "mis_ec2_backup_role" {
  name               = "${local.common_name}-mis-ec2-bkup-pri-iam"
  assume_role_policy = "${data.template_file.backup_assume_role_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "mis_ec2_backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = "${aws_iam_role.mis_ec2_backup_role.name}"
}
