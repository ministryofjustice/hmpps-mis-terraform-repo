locals {
  permission_denied_pattern = "failed to open stream Permission denied at"
}

#Alert permission denied on file
resource "aws_cloudwatch_metric_alarm" "file_permission_denied_alert" {
  alarm_name          = "${var.environment_type}__FilePermissionDeniedErrorCount__alert__Nextcloud"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FilePermissionDeniedErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Nextcloud File Permission error. Review log /${var.environment_type}/nextcloud/nextcloud.log. Ensure file owner is apache"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "file_permission_denied" {
  name           = "FilePermissionDeniedErrorCount"
  pattern        = local.permission_denied_pattern
  log_group_name = "/${var.environment_type}/nextcloud/nextcloud.log"

  metric_transformation {
    name      = "FilePermissionDeniedErrorCount"
    namespace = local.name_space
    value     = "1"
  }
}
