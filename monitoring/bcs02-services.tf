

resource "aws_cloudwatch_metric_alarm" "CMSTIER002_CentralManagementServer" {
  alarm_name                = "${local.environment_name}__CMSTIER002.CentralManagementServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.CMSTIER002_CentralManagementServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER002.CentralManagementServer Service in Error state on ndl-bcs-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER002_CentralManagementServer" {
 name           = "CMSTIER002.CentralManagementServer"
 pattern        = "CMSTIER002.CentralManagementServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER002_ConnectionServer" {
  alarm_name                = "${local.environment_name}__CMSTIER002.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.CMSTIER002_ConnectionServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER002.ConnectionServer Service in Error state on ndl-bcs-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER002_ConnectionServer" {
 name           = "CMSTIER002.ConnectionServer"
 pattern        = "CMSTIER002.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER002_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__CMSTIER002.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.CMSTIER002_ConnectionServer32.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER002.ConnectionServer32 Service in Error state on ndl-bcs-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER002_ConnectionServer32" {
 name           = "CMSTIER002.ConnectionServer32"
 pattern        = "CMSTIER002.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "CMSTIER002_APS_Search" {
  alarm_name                = "${local.environment_name}__CMSTIER002.APS.Search__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.CMSTIER002_APS_Search.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER002.APS.Search Service in Error state on ndl-bcs-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER002_APS_Search" {
 name           = "CMSTIER002.APS.Search"
 pattern        = "CMSTIER002.APS.Search"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
