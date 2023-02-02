#------------------------------------------------------------------------------------------------------------------
# Log Group
#------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "notify_slack_log_group" {
  name              = "/aws/lambda/${local.lambda_notify_slack_name}_log_group"
  retention_in_days = var.cloudwatch_log_retention
  tags = merge(
    local.tags,
    {
      "Name" = "${local.app_name}-scheduler-notify-slack-log-group"
    },
  )
}

#------------------------------------------------------------------------------------------------------------------
# SNS
#------------------------------------------------------------------------------------------------------------------
resource "aws_sns_topic" "alarm_notification" {
  name = "${local.app_name}-scheduler-alarm-notification"
}

resource "aws_sns_topic_subscription" "alarm_subscription" {
  count     = var.mis_alarms_enabled == "true" ? 1 : 0
  topic_arn = aws_sns_topic.alarm_notification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notify-ndmis-slack.arn
}

#------------------------------------------------------------------------------------------------------------------
# Notifying Slack Lambda function
#------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "notify-ndmis-slack" {
  filename         = data.archive_file.notify-ndmis-slack.output_path
  function_name    = local.lambda_notify_slack_name
  role             = aws_iam_role.lambda_notify_scheduler_role.arn
  handler          = "${local.lambda_notify_slack_name}.handler"
  source_code_hash = filebase64sha256(data.archive_file.notify-ndmis-slack.output_path)
  runtime          = "nodejs16.x"
  
  environment {
    variables = {
      REGION            = var.region
      ENVIRONMENT_TYPE  = var.environment_type
      SLACK_TOKEN       = local.slack_token_name  
      SLACK_CHANNEL     = var.environment_type == "prod" ? local.slack_prod_channel : local.slack_nonprod_channel
    }
  }
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify-ndmis-slack.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_notification.arn
}
