### SNS

locals {
  clamav_notification = "clamav-notification"
  lambda_name            = "${var.name}-${local.clamav_notification}"
}

resource "aws_sns_topic" "clamav-notification" {
  name = local.lambda_name
}

resource "aws_sns_topic_subscription" "clamav-notification" {
  topic_arn = aws_sns_topic.clamav-notification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.clamav-notification.arn
}

### Slack token URL details
data "aws_ssm_parameter" "slack_token_nonprod" {
  name            = "/mis/nonprod/slack/token"
}

data "aws_ssm_parameter" "slack_token_prod" {
  name            = "/mis/prod/slack/token"
}

### Lambda
data "archive_file" "clamav-notification" {
  type        = "zip"
  source_file = "${path.module}/lambda/${local.clamav_notification}.js"
  output_path = "${path.module}/files/${local.clamav_notification}.zip"
}

#data "aws_iam_role" "clamav-notification-role" {
#  name = "lambda_exec_role"
#}

resource "aws_lambda_function" "clamav-notification" {
  filename         = data.archive_file.clamav-notification.output_path
  function_name    = local.lambda_name
  role             = aws_iam_role.lambda_role.arn   # data.aws_iam_role.clamav-notification-role.arn
  handler          = "${local.clamav_notification}.handler"
  source_code_hash = filebase64sha256(data.archive_file.clamav-notification.output_path)
  runtime          = "nodejs12.x"

  environment {
    variables = {
      ENVIRONMENT_TYPE = var.name
      slack_url        = var.name == "prod" ? data.aws_ssm_parameter.slack_token_prod.value : data.aws_ssm_parameter.slack_token_nonprod.value    # "/services/T02DYEB3A/BS16X2JGY/r9e1CJYez7BDmwyliIl7WzLf"
      slack_channel    = var.name == "prod" ? "ndmis-alerts" : "ndmis-non-prod-alerts"
    }
  }
}

resource "aws_cloudwatch_log_group" "clamav-notification" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = "14"
  tags = merge(
    var.tags,
    {
      "Name" = "/aws/lambda/${local.lambda_name}"
    }
  )
}
