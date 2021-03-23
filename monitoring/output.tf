output "sns_topic_arn" {
  value = aws_sns_topic.alarm_notification.arn
}
