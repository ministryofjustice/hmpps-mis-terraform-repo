

resource "aws_cloudwatch_metric_alarm" "CMSTIER002_CentralManagementServer" {
  alarm_name                = "${local.environment_name}__CMSTIER002.CentralManagementServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER002CentralManagementServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER002.CentralManagementServer Service in Error state on ndl-bcs-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER002_CentralManagementServer" {
 name           = "CMSTIER002CentralManagementServerCount"
 pattern        = "${local.exclude_log_level} CMSTIER002.CentralManagementServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER002CentralManagementServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER002_ConnectionServer" {
  alarm_name                = "${local.environment_name}__CMSTIER002.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER002ConnectionServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER002.ConnectionServer Service in Error state on ndl-bcs-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER002_ConnectionServer" {
 name           = "CMSTIER002ConnectionServerCount"
 pattern        = "${local.exclude_log_level} CMSTIER002.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER002ConnectionServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER002_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__CMSTIER002.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER002ConnectionServer32Count"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER002.ConnectionServer32 Service in Error state on ndl-bcs-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER002_ConnectionServer32" {
 name           = "CMSTIER002ConnectionServer32Count"
 pattern        = "${local.exclude_log_level} CMSTIER002.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER002ConnectionServer32Count"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "CMSTIER002_APS_Search" {
  alarm_name                = "${local.environment_name}__CMSTIER002.APS.Search__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER002APSSearchCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER002.APS.Search Service in Error state on ndl-bcs-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER002_APS_Search" {
 name           = "CMSTIER002APSSearchCount"
 pattern        = "${local.exclude_log_level} CMSTIER002.APS.Search"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER002APSSearchCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
