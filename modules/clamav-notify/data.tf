### Slack token URL details
data "aws_ssm_parameter" "slack_token" {
  name            = "/${var.name}/slack/token"
}

### Lambda
data "archive_file" "clamav-notification" {
  type        = "zip"
  source_file = "${path.module}/lambda/${local.clamav_notification}.js"
  output_path = "${path.module}/files/${local.clamav_notification}.zip"
}

### IAM
data "aws_iam_role" "clamav-notification-role" {
  name = "delius-${var.name}-notify-slack-role"
}

