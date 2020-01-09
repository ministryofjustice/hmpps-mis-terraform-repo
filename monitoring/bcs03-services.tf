resource "aws_cloudwatch_metric_alarm" "CMSTIER003_APS_Core" {
  alarm_name                = "${local.environment_name}__CMSTIER003.APS.Core__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER003APSCoreCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER003.APS.Core Service in Error state on ndl-bcs-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER003_APS_Core" {
 name           = "CMSTIER003APSCoreCount"
 pattern        = "CMSTIER003.APS.Core"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER003APSCoreCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "CMSTIER003_APS_MonitoringService" {
  alarm_name                = "${local.environment_name}__CMSTIER003.APS.MonitoringService__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER003APSMonitoringServiceCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER003.APS.MonitoringService Service in Error state on ndl-bcs-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER003_APS_MonitoringService" {
 name           = "CMSTIER003APSMonitoringServiceCount"
 pattern        = "CMSTIER003.APS.MonitoringService"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER003APSMonitoringServiceCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER003_CentralManagementServer" {
  alarm_name                = "${local.environment_name}__CMSTIER003.CentralManagementServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER003CentralManagementServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER003.CentralManagementServer Service in Error state on ndl-bcs-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER003_CentralManagementServer" {
 name           = "CMSTIER003CentralManagementServerCount"
 pattern        = "CMSTIER003.CentralManagementServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER003CentralManagementServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "CMSTIER003_ConnectionServer" {
  alarm_name                = "${local.environment_name}__CMSTIER003.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER003ConnectionServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER003.ConnectionServer Service in Error state on ndl-bcs-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER003_ConnectionServer" {
 name           = "CMSTIER003ConnectionServerCount"
 pattern        = "CMSTIER003.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER003ConnectionServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER003_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__CMSTIER003.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER003ConnectionServer32Count"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER003.ConnectionServer32 Service in Error state on ndl-bcs-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER003_ConnectionServer32" {
 name           = "CMSTIER003ConnectionServer32Count"
 pattern        = "CMSTIER003.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER003ConnectionServer32Count"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER003_WebApplicationContainerServer" {
  alarm_name                = "${local.environment_name}__CMSTIER003.WebApplicationContainerServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER003WebApplicationContainerServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER003.WebApplicationContainerServer Service in Error state on ndl-bcs-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER003_WebApplicationContainerServer" {
 name           = "CMSTIER003WebApplicationContainerServerCount"
 pattern        = "CMSTIER003.WebApplicationContainerServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER003WebApplicationContainerServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
