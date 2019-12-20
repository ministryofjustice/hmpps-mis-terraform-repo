resource "aws_cloudwatch_metric_alarm" "PROCTIER001_AdaptiveJobServer" {
  alarm_name                = "${local.environment_name}__PROCTIER001.AdaptiveJobServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER001_AdaptiveJobServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER001.AdaptiveJobServer Service in Error state on ndl-bps-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER001_AdaptiveJobServer" {
 name           = "PROCTIER001.AdaptiveJobServer"
 pattern        = "PROCTIER001.AdaptiveJobServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER001_APS_Webi" {
  alarm_name                = "${local.environment_name}__PROCTIER001.APS.Webi__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER001_APS_Webi.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER001.APS.Webi Service in Error state on ndl-bps-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER001_APS_Webi" {
 name           = "PROCTIER001.APS.Webi"
 pattern        = "PROCTIER001.APS.Webi"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER001_ConnectionServer" {
  alarm_name                = "${local.environment_name}__PROCTIER001.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER001_ConnectionServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER001.ConnectionServer Service in Error state on ndl-bps-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER001_ConnectionServer" {
 name           = "PROCTIER001.ConnectionServer"
 pattern        = "PROCTIER001.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER001_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__PROCTIER001.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER001_ConnectionServer32.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER001.ConnectionServer32 Service in Error state on ndl-bps-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER001_ConnectionServer32" {
 name           = "PROCTIER001.ConnectionServer32"
 pattern        = "PROCTIER001.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER001_WebIntelligenceProcessingServer" {
  alarm_name                = "${local.environment_name}__PROCTIER001.WebIntelligenceProcessingServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER001_WebIntelligenceProcessingServer.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER001.WebIntelligenceProcessingServer Service in Error state on ndl-bps-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER001_WebIntelligenceProcessingServer" {
 name           = "PROCTIER001.WebIntelligenceProcessingServer"
 pattern        = "PROCTIER001.WebIntelligenceProcessingServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER001_WebIntelligenceProcessingServer1" {
  alarm_name                = "${local.environment_name}__PROCTIER001.WebIntelligenceProcessingServer1__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.PROCTIER001_WebIntelligenceProcessingServer1.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER001.WebIntelligenceProcessingServer1 Service in Error state on ndl-bps-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER001_WebIntelligenceProcessingServer1" {
 name           = "PROCTIER001.WebIntelligenceProcessingServer1"
 pattern        = "PROCTIER001.WebIntelligenceProcessingServer1"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "EventCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
