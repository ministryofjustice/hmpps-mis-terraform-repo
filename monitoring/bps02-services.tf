resource "aws_cloudwatch_metric_alarm" "PROCTIER002_AdaptiveJobServer" {
  alarm_name                = "${local.environment_name}__PROCTIER002.AdaptiveJobServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER002_AdaptiveJobServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.AdaptiveJobServer Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_AdaptiveJobServer" {
 name           = "PROCTIER002.AdaptiveJobServer"
 pattern        = "PROCTIER002.AdaptiveJobServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER002_APS_Webi" {
  alarm_name                = "${local.environment_name}__PROCTIER002.APS.Webi__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER002_APS_Webi.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.APS.Webi Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_APS_Webi" {
 name           = "PROCTIER002.APS.Webi"
 pattern        = "PROCTIER002.APS.Webi"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER002_ConnectionServer" {
  alarm_name                = "${local.environment_name}__PROCTIER002.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER002_ConnectionServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.ConnectionServer Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_ConnectionServer" {
 name           = "PROCTIER002.ConnectionServer"
 pattern        = "PROCTIER002.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER002_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__PROCTIER002.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER002_ConnectionServer32.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.ConnectionServer32 Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_ConnectionServer32" {
 name           = "PROCTIER002.ConnectionServer32"
 pattern        = "PROCTIER002.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER002_WebIntelligenceProcessingServer" {
  alarm_name                = "${local.environment_name}__PROCTIER002.WebIntelligenceProcessingServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER002_WebIntelligenceProcessingServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.WebIntelligenceProcessingServer Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_WebIntelligenceProcessingServer" {
 name           = "PROCTIER002.WebIntelligenceProcessingServer"
 pattern        = "PROCTIER002.WebIntelligenceProcessingServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER002_WebIntelligenceProcessingServer1" {
  alarm_name                = "${local.environment_name}__PROCTIER002.WebIntelligenceProcessingServer1__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER002_WebIntelligenceProcessingServer1.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER002.WebIntelligenceProcessingServer1 Service in Error state on ndl-bps-002. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER002_WebIntelligenceProcessingServer1" {
 name           = "PROCTIER002.WebIntelligenceProcessingServer1"
 pattern        = "PROCTIER002.WebIntelligenceProcessingServer1"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
