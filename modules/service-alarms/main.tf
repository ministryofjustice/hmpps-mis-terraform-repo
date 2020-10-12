#ALARM Notification
resource "aws_cloudwatch_metric_alarm" "mis_service_alarm" {
  alarm_name          = "${var.alarm_name}__critical"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "${var.metric_name}Count"
  namespace           = var.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "${var.service_name} Service in Error state on ${var.host}. ${var.mis_team_action}"
  alarm_actions       = [var.alarm_actions]
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = "1"
}

#Alarm Metric Filter
resource "aws_cloudwatch_log_metric_filter" "mis_service_metric" {
  name           = "${var.metric_name}Count"
  pattern        = var.pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "${var.metric_name}Count"
    namespace = var.name_space
    value     = "1"
  }
}

##OK ALARM
resource "aws_cloudwatch_metric_alarm" "mis_service_alarm_OK" {
  alarm_name          = "${var.alarm_name}__OK"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "${var.metric_name}Count_OK"
  namespace           = var.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "${var.service_name} Service in Error state on ${var.host}. ${var.mis_team_action}"
  alarm_actions       = [var.alarm_actions]
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = "1"
}

#OK Metric Filter
resource "aws_cloudwatch_log_metric_filter" "mis_service_metric_OK" {
  name           = "${var.metric_name}Count_OK"
  pattern        = var.pattern_ok
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "${var.metric_name}Count_OK"
    namespace = var.name_space
    value     = "1"
  }
}

