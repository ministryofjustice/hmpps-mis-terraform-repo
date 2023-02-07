output "sns_topic_arn" {
  value = aws_sns_topic.alarm_notification.arn
}

output "slack_token_name" {
  value = aws_ssm_parameter.slack_token.name
}
