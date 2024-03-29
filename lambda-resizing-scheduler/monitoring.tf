#------------------------------------------------------------------------------------------------------------------
# CloudWatch Log
#------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "scheduler" {
  name              = local.resizing_scheduler_log_group 
  retention_in_days = var.cloudwatch_log_retention
  tags = merge(
    local.tags,
    {
      "Name" = local.resizing_scheduler_log_group
    },
  )
}

#------------------------------------------------------------------------------------------------------------------
# Lambda Alert
#------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "lambda_errors_alert" {
  alarm_name          = "${var.environment_identifier}__etl_scheduler__alert__scheduler_Errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This alarm returns any ETL Resizing Scheduler Errors. For more details about the error(s) found, please review log group ${local.resizing_scheduler_log_group}"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
  dimensions = {
    FunctionName = "${aws_lambda_function.modify-ec2-instance-type.function_name}"
    Resource     = "${aws_lambda_function.modify-ec2-instance-type.function_name}"
  }
}