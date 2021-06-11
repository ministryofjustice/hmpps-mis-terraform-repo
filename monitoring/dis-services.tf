### Terraform modules ###
locals {
  #DIS ETL VARS
  host_dis1                   = "ndl-dis-${local.nart_prefix}1"
  pattern_host_name            = "NDLDIS${local.nart_prefix}1"
  Central_Management_Server    = "CentralManagementServer"
  File_Repository             = "File Repository"
  Central_Management          = "Central Management"
  Job_Server                  = "Job"
  EIMAdaptiveProcessingServer = "EIMAdaptiveProcessingServer"
  AdaptiveProcessingServer    = "AdaptiveProcessingServer"
  DataServices                = "DataServices"
  data_services_pattern       = "Data Services"
  dis_server_stopped_msg      = "Server stopped"
  dis_server_started_msg      = "Server started"
  stopped_with_exit_code      = "stopped with exit code"
  match_all_patterns          = " "  #match all patterns
  mis_etl_metric_name         = "DisEtlErrorsCount"
  etl_log_group_name          = "/mis/extraction/transformation/loading/log"
}

#--------------------------------------------------------
#DIS Service Alarms
#--------------------------------------------------------
module "File_Repository" {
  source          = "../modules/service-alarms/"
  service_name    = "File_Repository"
  alarm_name      = "${local.environment_name}__Dis_File_Repository"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.host_dis1} ${local.File_Repository} ${local.dis_server_stopped_msg}"
  log_group_name  = local.log_group_name
  metric_name     = "DisFileRepository"
  pattern_ok      = "${local.include_log_level} ${local.host_dis1} ${local.File_Repository} ${local.dis_server_started_msg}"
  tags            = local.tags
}

module "Central_Management" {
  source          = "../modules/service-alarms/"
  service_name    = "Central_Management"
  alarm_name      = "${local.environment_name}__Dis_Central_Management"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.host_dis1} ${local.Central_Management} ${local.dis_server_stopped_msg}"
  log_group_name  = local.log_group_name
  metric_name     = "DisCentralManagement"
  pattern_ok      = "${local.include_log_level} ${local.host_dis1} ${local.Central_Management} ${local.dis_server_started_msg}"
  tags            = local.tags
}

module "Job_Server" {
  source          = "../modules/service-alarms/"
  service_name    = "Job_Server"
  alarm_name      = "${local.environment_name}__Dis_Job_Server"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.host_dis1} ${local.Job_Server} ${local.dis_server_stopped_msg}"
  log_group_name  = local.log_group_name
  metric_name     = "DisJobServer"
  pattern_ok      = "${local.include_log_level} ${local.host_dis1} ${local.Job_Server} ${local.dis_server_started_msg}"
  tags            = local.tags
}

module "AdaptiveProcessingServer" {
  source          = "../modules/service-alarms/"
  service_name    = local.AdaptiveProcessingServer
  alarm_name      = "${local.environment_name}__Dis_${local.AdaptiveProcessingServer}"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.pattern_host_name}.${local.AdaptiveProcessingServer} ${local.stopped_with_exit_code}"
  log_group_name  = local.log_group_name
  metric_name     = "Dis${local.AdaptiveProcessingServer}"
  pattern_ok      = "${local.include_log_level} ${local.pattern_host_name}.${local.AdaptiveProcessingServer} ${local.started_message}"
  tags            = local.tags
}

module "EIMAdaptiveProcessingServer" {
  source          = "../modules/service-alarms/"
  service_name    = local.EIMAdaptiveProcessingServer
  alarm_name      = "${local.environment_name}__Dis_${local.EIMAdaptiveProcessingServer}"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.pattern_host_name}.${local.EIMAdaptiveProcessingServer} ${local.stopped_with_exit_code}"
  log_group_name  = local.log_group_name
  metric_name     = "Dis${local.EIMAdaptiveProcessingServer}"
  pattern_ok      = "${local.include_log_level} ${local.pattern_host_name}.${local.EIMAdaptiveProcessingServer} ${local.started_message}"
  tags            = local.tags
}

module "DataServices" {
  source          = "../modules/service-alarms/"
  service_name    = local.DataServices
  alarm_name      = "${local.environment_name}__Dis_${local.DataServices}"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.data_services_pattern} ${local.host_dis1} In ServiceStop"
  log_group_name  = local.log_group_name
  metric_name     = "Dis${local.DataServices}"
  pattern_ok      = "${local.include_log_level} ${local.data_services_pattern} ${local.host_dis1} In ServiceStart"
  tags            = local.tags
}

module "CentralManagementServer" {
  source          = "../modules/service-alarms/"
  service_name    = local.Central_Management_Server
  alarm_name      = "${local.environment_name}__Dis_${local.Central_Management_Server}"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.pattern_host_name}.${local.Central_Management_Server} Service stopped unexpectedly."
  log_group_name  = local.log_group_name
  metric_name     = "DisCentralManagementServer"
  pattern_ok      = "${local.include_log_level} ${local.pattern_host_name}.${local.Central_Management_Server} ${local.started_message}"
  tags            = local.tags
}


#--------------------------------------------------------
#MIS ETL Alarms + Metric filter
#Log is if there is any data in the error_* file, an error has occured.
#Any log entry triggers alarm
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "mis_etl_alarm" {
  alarm_name          = "${local.environment_name}__Dis_ETL_ERRORS__critical"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = local.mis_etl_metric_name
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "MIS/Delius ETL Run Errors detected in error logs on host ${local.host_dis1}. The latest error_* file is more than 0kb in size. Please review the Cloudwatch Log group : ${local.etl_log_group_name} for more details"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = "1"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "mis_etl_service_metric" {
  name           = local.mis_etl_metric_name
  pattern        = local.match_all_patterns
  log_group_name = local.etl_log_group_name

  metric_transformation {
    name      = local.mis_etl_metric_name
    namespace = local.name_space
    value     = "1"
  }
}
