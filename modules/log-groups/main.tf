resource "aws_cloudwatch_log_group" "aws_cloudwatch_logs" {
  name              = "${var.name}"
  retention_in_days = "${var.retention_in_days}"
  tags              = "${var.tags}"
}
