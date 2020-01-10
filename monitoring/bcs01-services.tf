 resource "aws_cloudwatch_metric_alarm" "CMSTIER001_APS_Core" {
   alarm_name                = "${local.environment_name}__CMSTIER001.APS.Core__critical"
   comparison_operator       = "GreaterThanOrEqualToThreshold"
   evaluation_periods        = "1"
   metric_name               = "CMSTIER001APSCoreCount"
   namespace                 = "${local.name_space}"
   period                    = "60"
   statistic                 = "Sum"
   threshold                 = "1"
   alarm_description         = "CMSTIER001.APS.Core Service in Error state on ndl-bcs-001. Please contact the MIS Team"
   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
   treat_missing_data        = "notBreaching"
   datapoints_to_alarm       = "1"
 }

resource "aws_cloudwatch_log_metric_filter" "CMSTIER001_APS_Core" {
  name           = "CMSTIER001APSCoreCount"
  pattern        = "${local.exclude_log_level} CMSTIER001.APS.Core"
  log_group_name = "${local.log_group_name}"

  metric_transformation {
    name      = "CMSTIER001APSCoreCount"
    namespace = "${local.name_space}"
    value     = "1"
  }
}



resource "aws_cloudwatch_metric_alarm" "CMSTIER001_APS_PromotionManager" {
  alarm_name                = "${local.environment_name}__CMSTIER001.APS.PromotionManager__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER001APSPromotionManagerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER001.APS.PromotionManager Service in Error state on ndl-bcs-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER001_APS_PromotionManager" {
 name           = "CMSTIER001APSPromotionManagerCount"
 pattern        = "${local.exclude_log_level} CMSTIER001.APS.PromotionManager"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER001APSPromotionManagerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "CMSTIER001_CentralManagementServer" {
  alarm_name                = "${local.environment_name}__CMSTIER001.CentralManagementServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER001CentralManagementServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER001.CentralManagementServer Service in Error state on ndl-bcs-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER001_CentralManagementServer" {
 name           = "CMSTIER001CentralManagementServerCount"
 pattern        = "${local.exclude_log_level} CMSTIER001.CentralManagementServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER001CentralManagementServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "CMSTIER001_ConnectionServer" {
  alarm_name                = "${local.environment_name}__CMSTIER001.ConnectionServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER001ConnectionServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER001.ConnectionServer Service in Error state on ndl-bcs-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER001_ConnectionServer" {
 name           = "CMSTIER001ConnectionServerCount"
 pattern        = "${local.exclude_log_level} CMSTIER001.ConnectionServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER001ConnectionServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER001_ConnectionServer32" {
  alarm_name                = "${local.environment_name}__CMSTIER001.ConnectionServer32__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER001ConnectionServer32Count"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER001.ConnectionServer32 Service in Error state on ndl-bcs-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER001_ConnectionServer32" {
 name           = "CMSTIER001ConnectionServer32Count"
 pattern        = "${local.exclude_log_level} CMSTIER001.ConnectionServer32"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER001ConnectionServer32Count"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "CMSTIER001_EventServer" {
  alarm_name                = "${local.environment_name}__CMSTIER001.EventServer__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER001EventServerCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER001.EventServer Service in Error state on ndl-bcs-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER001_EventServer" {
 name           = "CMSTIER001EventServerCount"
 pattern        = "${local.exclude_log_level} CMSTIER001.EventServer"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER001EventServerCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}


resource "aws_cloudwatch_metric_alarm" "CMSTIER001_InputFilerepository" {
  alarm_name                = "${local.environment_name}__CMSTIER001.InputFilerepository__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER001InputFilerepositoryCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER001.InputFilerepository Service in Error state on ndl-bcs-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER001_InputFilerepository" {
 name           = "CMSTIER001InputFilerepositoryCount"
 pattern        = "${local.exclude_log_level} CMSTIER001.InputFilerepository"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER001InputFilerepositoryCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}

resource "aws_cloudwatch_metric_alarm" "CMSTIER001_OutputFilerepository" {
  alarm_name                = "${local.environment_name}__CMSTIER001.OutputFilerepository__critical"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CMSTIER001OutputFilerepositoryCount"
  namespace                 = "${local.name_space}"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "CMSTIER001.OutputFilerepository Service in Error state on ndl-bcs-001. Please contact the MIS Team"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
  datapoints_to_alarm       = "1"
}

resource "aws_cloudwatch_log_metric_filter" "CMSTIER001_OutputFilerepository" {
 name           = "CMSTIER001OutputFilerepositoryCount"
 pattern        = "${local.exclude_log_level} CMSTIER001.OutputFilerepository"
 log_group_name = "${local.log_group_name}"

 metric_transformation {
   name      = "CMSTIER001OutputFilerepositoryCount"
   namespace = "${local.name_space}"
   value     = "1"
 }
}
