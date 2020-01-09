resource "aws_cloudwatch_metric_alarm" "bws_httpd" {
  alarm_name                = "${local.environment_name}__httpd__critical__bws"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "BwsHttpdCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "httpd Service in Error state on BWS Hosts. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "bws_httpd" {
 name           = "BwsHttpdCount"
 pattern        = "httpd"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "BwsHttpdCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "bws_Tomcat" {
  alarm_name                = "${local.environment_name}__Tomcat__critical__bws"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "BwsTomcatCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Tomcat Service in Error state on BWS Hosts. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "bws_Tomcat" {
 name           = "BwsTomcatCount"
 pattern        = "Tomcat"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "BwsTomcatCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


#####ETL
resource "aws_cloudwatch_metric_alarm" "etl" {
  alarm_name                = "${local.environment_name}__ETL__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "EtlCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "ETL Job Service in Error state on ndl-dis-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}


resource "aws_cloudwatch_log_metric_filter" "etl" {
 name           = "EtlCount"
 pattern        = "01.CentralManagementServer stopped unexpectedly."
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EtlCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
