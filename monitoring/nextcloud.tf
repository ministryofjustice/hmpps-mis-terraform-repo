locals {
  permission_denied_pattern = "failed to open stream Permission denied at"
  wmt_upload_log_group      = "/${var.environment_type}/nextcloud/wmt_log"
}

#-------------------------------------------------------------
# Alert permission denied on file
#-------------------------------------------------------------
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

#-------------------------------------------------------------
# WMT Upload Failure Alert
#-------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wmt_upload_alert" {
  alarm_name          = "${var.environment_type}__WmtUploadError__alert__Nextcloud"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "WmtUploadErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "WMT Upload Error failure. Review log ${local.wmt_upload_log_group}. Rerun script /usr/local/sbin/s3_upload_wmt.sh on any of the Nextcloud EC2 instances"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "wmt_upload_alert" {
  name           = "WmtUploadErrorCount"
  pattern        = "Failure"
  log_group_name = local.wmt_upload_log_group

  metric_transformation {
    name      = "WmtUploadErrorCount"
    namespace = local.name_space
    value     = "1"
  }
}
