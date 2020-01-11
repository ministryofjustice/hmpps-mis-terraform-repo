resource "aws_cloudwatch_metric_alarm" "PROCTIER003_AdaptiveJobServer" {
  alarm_name                = "${local.environment_name}__PROCTIER003.AdaptiveJobServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER003AdaptiveJobServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.AdaptiveJobServer Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_AdaptiveJobServer" {
 name           = "PROCTIER003AdaptiveJobServerCount"
 pattern        = "${local.exclude_log_level} PROCTIER003.AdaptiveJobServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER003AdaptiveJobServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER003_APS_Webi" {
  alarm_name                = "${local.environment_name}__PROCTIER003.APS.Webi__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER003APSWebiCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.APS.Webi Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_APS_Webi" {
 name           = "PROCTIER003APSWebiCount"
 pattern        = "${local.exclude_log_level} PROCTIER003.APS.Webi"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER003APSWebiCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER003_ConnectionServer" {
  alarm_name                = "${local.environment_name}__PROCTIER003.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER003ConnectionServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.ConnectionServer Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_ConnectionServer" {
 name           = "PROCTIER003ConnectionServerCount"
 pattern        = "${local.exclude_log_level} PROCTIER003.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER003ConnectionServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "PROCTIER003_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__PROCTIER003.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER003ConnectionServer32Count"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.ConnectionServer32 Service in Error state on ndl-bps-003. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_ConnectionServer32" {
 name           = "PROCTIER003ConnectionServer32Count"
 pattern        = "${local.exclude_log_level} PROCTIER003.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER003ConnectionServer32Count"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "PROCTIER003_WebIntelligenceProcessingServer" {
  alarm_name                = "${local.environment_name}__PROCTIER003.WebIntelligenceProcessingServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER003WebIntelligenceProcessingServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.WebIntelligenceProcessingServer Service in Error state on ndl-bps-003. If no OK alarm is recieved in a few minutes, please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_WebIntelligenceProcessingServer" {
 name           = "PROCTIER003WebIntelligenceProcessingServerCount"
 pattern        = "${local.exclude_log_level} PROCTIER003.WebIntelligenceProcessingServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER003WebIntelligenceProcessingServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

##PROCTIER003.WebIntelligenceProcessingServer OK ALARM
resource "aws_cloudwatch_metric_alarm" "PROCTIER003_WebIntelligenceProcessingServer_OK" {
  alarm_name                = "${local.environment_name}__PROCTIER003.WebIntelligenceProcessingServer__OK"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER003WebIntelligenceProcessingServerCount_OK"
  namespace                 = "${local.name_space}"
  period                    = "120"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.WebIntelligenceProcessingServer Service in Error state on ndl-bps-003. If no OK alarm is recieved in a few minutes, please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_WebIntelligenceProcessingServer_OK" {
 name           = "PROCTIER003WebIntelligenceProcessingServerCount_OK"
 pattern        = "INFORMATION PROCTIER003.WebIntelligenceProcessingServer has been started"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER003WebIntelligenceProcessingServerCount_OK"
   namespace = "${local.name_space}"
   value     = "1"
 }
}



resource "aws_cloudwatch_metric_alarm" "PROCTIER003_WebIntelligenceProcessingServer1" {
  alarm_name                = "${local.environment_name}__PROCTIER003.WebIntelligenceProcessingServer1__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER003WebIntelligenceProcessingServer1Count"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.WebIntelligenceProcessingServer1 Service in Error state on ndl-bps-003. If no OK alarm is recieved in a few minutes, please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_WebIntelligenceProcessingServer1" {
 name           = "PROCTIER003WebIntelligenceProcessingServer1Count"
 pattern        = "${local.exclude_log_level} PROCTIER003.WebIntelligenceProcessingServer1"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER003WebIntelligenceProcessingServer1Count"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

##PROCTIER003.WebIntelligenceProcessingServer1 OK ALARM
resource "aws_cloudwatch_metric_alarm" "PROCTIER003_WebIntelligenceProcessingServer1_OK" {
  alarm_name                = "${local.environment_name}__PROCTIER003.WebIntelligenceProcessingServer1__OK"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "PROCTIER003WebIntelligenceProcessingServer1Count_OK"
  namespace                 = "${local.name_space}"
  period                    = "120"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "PROCTIER003.WebIntelligenceProcessingServer1 Service in Error state on ndl-bps-003. If no OK alarm is recieved in a few minutes, please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "PROCTIER003_WebIntelligenceProcessingServer1_OK" {
 name           = "PROCTIER003WebIntelligenceProcessingServer1Count_OK"
 pattern        = "INFORMATION PROCTIER003.WebIntelligenceProcessingServer1 has been started"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "PROCTIER003WebIntelligenceProcessingServer1Count_OK"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
