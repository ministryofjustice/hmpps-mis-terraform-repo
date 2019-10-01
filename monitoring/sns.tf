### SNS

resource "aws_sns_topic" "alarm_notification" {
  name               = "${local.environment_identifier}-${local.mis_app_name}-alarm-notification"
}

resource "aws_sns_topic_subscription" "alarm_subscription" {
  count              = "${var.alarms_enabled == "true" ? 1 : 0}"
  topic_arn          = "${aws_sns_topic.alarm_notification.arn}"
  protocol           = "lambda"
  endpoint           = "${aws_lambda_function.notify-ops-slack.arn}"
}

### Lambda

locals {
  lambda_name = "${local.environment_identifier}-${local.mis_app_name}-notify-ops-slack"
}

data "archive_file" "notify-ops-slack" {
  type               = "zip"
  source_file        = "${path.module}/lambda/${local.lambda_name}.js"
  output_path        = "${path.module}/files/${local.lambda_name}zip"
}

data "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
}

resource "aws_lambda_function" "notify-ops-slack" {
  filename           = "${data.archive_file.notify-ops-slack.output_path}"
  function_name      = "${local.lambda_name}"
  role               = "${data.aws_iam_role.lambda_exec_role.arn}"
  handler            = "${local.lambda_name}.handler"
  source_code_hash   = "${base64sha256(file("${data.archive_file.notify-ops-slack.output_path}"))}"
  runtime            = "nodejs8.10"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id        = "AllowExecutionFromSNS"
  action              = "lambda:InvokeFunction"
  function_name       = "${aws_lambda_function.notify-ops-slack.arn}"
  principal           = "sns.amazonaws.com"
  source_arn          = "${aws_sns_topic.alarm_notification.arn}"
}
