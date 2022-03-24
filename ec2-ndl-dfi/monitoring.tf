#--------------------------------------------------------
#Datasync alerts
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "datasync_error_alert" {
  alarm_name          = "${var.environment_type}__datasync_error__alert__DFI_Datasync"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DataSyncErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Datasync Error, DFI File transfer error. May affect DFI ETL run. Please review log group ${local.datasync_log_group}"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "datasync_error_alert" {
  name           = "DataSyncErrorCount"
  pattern        = local.error_pattern
  log_group_name = local.datasync_log_group

  metric_transformation {
    name      = "DataSyncErrorCount"
    namespace = local.name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "datasync_creds_error_alert" {
  alarm_name          = "${var.environment_type}__datasync_creds_error__alert__DFI_Datasync"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DataSyncCredsErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Datasync Task Execution finished with status S3 Volume did not receive creds for location. Please re-run Codepipeline: ${var.environment_name}-dfi-s3-fsx"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "datasync_creds_error_alert" {
  name           = "DataSyncCredsErrorCount"
  pattern        = local.creds_error_pattern
  log_group_name = local.datasync_log_group

  metric_transformation {
    name      = "DataSyncCredsErrorCount"
    namespace = local.name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "datasync_verification_alert" {
  alarm_name          = "${var.environment_type}__datasync_verification_error__alert__DFI_Datasync"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DataSyncVerificationErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "DFI Datasync Verification Error. Please review log group ${local.datasync_log_group}"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "datasync_verification_alert" {
  name           = "DataSyncVerificationErrorCount"
  pattern        = local.verification_error_pattern
  log_group_name = local.datasync_log_group

  metric_transformation {
    name      = "DataSyncVerificationErrorCount"
    namespace = local.name_space
    value     = "1"
  }
}

#--------------------------------------------------------
# CPU Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_cpu_critical" {
  count = length(
    local.dfi_instance_ids,
  )
  alarm_name          = "${var.environment_type}__CPU-Utilization__critical__DFI__${local.dfi_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "CPU utilization is averaging 92% for ${local.dfi_primary_dns_ext[count.index]}. Please note: During the ETL Run it is normal for resource usage to be high, daily between 18:30-00:00 & 01:00-05:30 when this can be ignored. Otherwise contact the MIS Team or AWS Support Contact."
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  tags                = local.tags

  dimensions = {
    InstanceId = local.dfi_instance_ids[count.index]
  }
}

#--------------------------------------------------------
#Disk Usage Alert
#--------------------------------------------------------
module "dfi" {
  source             = "../modules/disk-usage-alarms/"
  component          = "DFI"
  objectname         = "LogicalDisk"
  alert_threshold    = "25"
  critical_threshold = "5"
  period             = "60"
  environment_name   = var.environment_type
  instance_ids       = local.dfi_instance_ids
  primary_dns_ext    = local.dfi_primary_dns_ext
  ami_id             = local.dfi_ami_id
  instance_type      = local.dfi_instance_type
  sns_topic          = local.sns_topic_arn
  tags               = local.tags
}

#--------------------------------------------------------
#Instance Health Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_instance-health-check" {
  count = length(
    local.dfi_instance_ids,
  )
  alarm_name          = "${var.environment_type}__StatusCheckFailed__critical__DIS__${local.dfi_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "EC2 Health status failed for ${local.dfi_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  tags                = local.tags

  dimensions = {
    InstanceId = local.dfi_instance_ids[count.index]
  }
}



#--------------------------------------------------------
#DFI LB Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_lb_unhealthy_hosts_critical" {
count = length(
  local.dfi_instance_ids,
)
  alarm_name          = "${var.environment_type}__UnHealthyHostCount__critical__DFI__${local.dfi_lb_name}-lb"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "The DFI loadbalancer ${local.dfi_lb_name} has 1 Unhealthy host. Please contact the MIS Team or the MIS AWS Support contact"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  tags                = local.tags

  dimensions = {
    LoadBalancerName = local.dfi_lb_name
  }
}

#--------------------------------------------------------
#DFI Memory Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_instance-memory-critical" {
  count = length(
    local.dfi_instance_ids,
  )
  alarm_name          = "${var.environment_type}__Memory-Utilization__critical__DFI__${local.dfi_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "Memory Utilization  is averaging 92% for ${local.dfi_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  tags                = local.tags

  dimensions = {
    InstanceId   = local.dfi_instance_ids[count.index]
    ImageId      = local.dfi_ami_id[count.index]
    InstanceType = local.dfi_instance_type[count.index]
    objectname   = "Memory"
  }
}

#--------------------------------------------------------
#DFI Lambda Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "s3_events_error_alert" {
  alarm_name          = "${var.environment_type}__dfi_s3_events__alert__DFI_S3Events"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DfiS3EventsErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "DFI S3 Event Lambda Invoke Error. May affect DFI File Transfer from S3 to FSX and DFI ETL run. Please review log group ${local.dfi_lambda_log_group}"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "s3_events_error_alert" {
  name           = "DfiS3EventsErrorCount"
  pattern        = local.dfi_lambda_error_pattern
  log_group_name = local.dfi_lambda_log_group

  metric_transformation {
    name      = "DfiS3EventsErrorCount"
    namespace = local.name_space
    value     = "1"
  }
  depends_on = [aws_cloudwatch_log_group.dfi_lambda]
}

#--------------------------------------------------------
#DFI ClamAV Alerts
#Notify in slack that infected files found
#--------------------------------------------------------
module "clamav-notify" {
  source  = "../modules/clamav-notify/"
  name    = var.environment_type
  tags    = local.tags
}

#--------------------------------------------------------
#DFI ETL Alarms + Metric filter
#Log is if there is any data in the error_* file, an error has occured.
#Any log entry triggers alarm
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_etl_alarm" {
  alarm_name          = "${var.environment_type}__DFI_ETL_ERRORS__critical"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = local.dfi_etl_metric_name
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "DFI ETL Run Errors detected in error logs on host ${local.host_dfi1}. The latest error_* file is more than 0kb in size. Please review the Cloudwatch Log group : ${local.dfi_etl_log_group_name} for more details"
  alarm_actions       = [local.sns_topic_arn]
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = "1"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "dfi_etl_service_metric" {
  name           = local.dfi_etl_metric_name
  pattern        = local.match_all_patterns
  log_group_name = local.dfi_etl_log_group_name

  metric_transformation {
    name      = local.dfi_etl_metric_name
    namespace = local.name_space
    value     = "1"
  }
  depends_on = [aws_cloudwatch_log_group.dfi_etl_log_group]
}

#--------------------------------------------------------
#ETL Cloudwatch Log group
#--------------------------------------------------------

resource "aws_cloudwatch_log_group" "dfi_etl_log_group" {
  name              = local.dfi_etl_log_group_name
  retention_in_days = "14"
  tags = merge(
    local.tags,
    {
      "Name" = local.dfi_etl_log_group_name
    },
  )
}

#--------------------------------------------------------
#DFI Pipeline Failure Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dfi_pipeline_alert" {
  alarm_name          = "${var.environment_type}__dfi_pipeline_errors__alert"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DfiPipelineErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "DFI CodePipeline ${var.environment_name}-dfi-s3-fsx completed with errors. Please review log group ${local.dfi_pipeline_log_group_name}"
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "dfi_pipeline_alert" {
  name           = "DfiPipelineErrorCount"
  pattern        = local.dfi_pipeline_failure_pattern
  log_group_name = local.dfi_pipeline_log_group_name

  metric_transformation {
    name      = "DfiPipelineErrorCount"
    namespace = local.name_space
    value     = "1"
  }
}
