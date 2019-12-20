resource "aws_cloudwatch_metric_alarm" "PROCTIER003_AdaptiveJobServer" {
  alarm_name                = "${local.environment_name}__PROCTIER003.AdaptiveJobServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER003_AdaptiveJobServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.AdaptiveJobServer Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_AdaptiveJobServer" {
 name           = "PROCTIER003.AdaptiveJobServer"
 pattern        = "PROCTIER003.AdaptiveJobServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER003_APS_Webi" {
  alarm_name                = "${local.environment_name}__PROCTIER003.APS.Webi__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER003_APS_Webi.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.APS.Webi Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_APS_Webi" {
 name           = "PROCTIER003.APS.Webi"
 pattern        = "PROCTIER003.APS.Webi"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER003_ConnectionServer" {
  alarm_name                = "${local.environment_name}__PROCTIER003.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER003_ConnectionServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.ConnectionServer Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_ConnectionServer" {
 name           = "PROCTIER003.ConnectionServer"
 pattern        = "PROCTIER003.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER003_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__PROCTIER003.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER003_ConnectionServer32.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.ConnectionServer32 Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_ConnectionServer32" {
 name           = "PROCTIER003.ConnectionServer32"
 pattern        = "PROCTIER003.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER003_WebIntelligenceProcessingServer" {
  alarm_name                = "${local.environment_name}__PROCTIER003.WebIntelligenceProcessingServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER003_WebIntelligenceProcessingServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.WebIntelligenceProcessingServer Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_WebIntelligenceProcessingServer" {
 name           = "PROCTIER003.WebIntelligenceProcessingServer"
 pattern        = "PROCTIER003.WebIntelligenceProcessingServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER003_WebIntelligenceProcessingServer1" {
  alarm_name                = "${local.environment_name}__PROCTIER003.WebIntelligenceProcessingServer1__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER003_WebIntelligenceProcessingServer1.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.WebIntelligenceProcessingServer1 Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_WebIntelligenceProcessingServer1" {
 name           = "PROCTIER003.WebIntelligenceProcessingServer1"
 pattern        = "PROCTIER003.WebIntelligenceProcessingServer1"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
