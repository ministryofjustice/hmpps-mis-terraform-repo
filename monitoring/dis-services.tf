### Terraform modules ###
locals {
  host_dis1                   = "ndl-dis-${local.nart_prefix}1"
  match_all_patterns          = " "  #match all patterns
  mis_etl_metric_name         = "DisEtlErrorsCount"
  etl_log_group_name          = "/mis/extraction/transformation/loading/log"
}

#--------------------------------------------------------
#MIS ETL Alarms + Metric filter
#Log is if there is any data in the error_* file, an error has occured.
#Any log entry triggers alarm
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "mis_etl_alarm" {
  alarm_name          = "${var.environment_type}__Dis_ETL_ERRORS__critical"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = local.mis_etl_metric_name
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "MIS/Delius ETL Run Errors detected in error logs on host ${local.host_dis1}. The latest error_* file is more than 0kb in size. Please review the Cloudwatch Log group : ${local.etl_log_group_name} for more details"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = "1"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "mis_etl_service_metric" {
  name           = local.mis_etl_metric_name
  pattern        = local.match_all_patterns
  log_group_name = local.etl_log_group_name

  metric_transformation {
    name      = local.mis_etl_metric_name
    namespace = local.name_space
    value     = "1"
  }
}
