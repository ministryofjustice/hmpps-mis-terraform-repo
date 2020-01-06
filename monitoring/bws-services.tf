resource "aws_cloudwatch_metric_alarm" "bws_httpd" {
  alarm_name                = "${local.environment_name}__httpd__critical__bws"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.bws_httpd.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "httpd Service in Error state on BWS Hosts. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "bws_httpd" {
 name           = "httpd"
 pattern        = "httpd"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "bws_Tomcat" {
  alarm_name                = "${local.environment_name}__Tomcat__critical__bws"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.bws_Tomcat.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Tomcat Service in Error state on BWS Hosts. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "bws_Tomcat" {
 name           = "Tomcat"
 pattern        = "Tomcat"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
