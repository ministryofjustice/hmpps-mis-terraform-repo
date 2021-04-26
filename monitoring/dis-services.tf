### Terraform modules ###
locals {
  #DIS ETL VARS
  host_dis1                   = "ndl-dis-${local.nart_prefix}1"
  patter_host_name            = "NDLDIS${local.nart_prefix}1"
  ETL                         = "01.CentralManagementServer"
  File_Repository             = "File Repository"
  Central_Management          = "Central Management"
  Job_Server                  = "Job"
  EIMAdaptiveProcessingServer = "EIMAdaptiveProcessingServer"
  AdaptiveProcessingServer    = "AdaptiveProcessingServer"
  DataServices                = "DataServices"
  dis_server_stopped_msg      = "Server stopped"
  dis_server_started_msg      = "Server started"
  stopped_with_exit_code      = "stopped with exit code"
}

################################################
#
#            ALARMS DIS1
#
################################################
module "File_Repository" {
  source          = "../modules/service-alarms/"
  service_name    = "File_Repository"
  alarm_name      = "${local.environment_name}__File_Repository"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.File_Repository} ${local.dis_server_stopped_msg}"
  log_group_name  = local.log_group_name
  metric_name     = "FileRepository"
  pattern_ok      = "${local.include_log_level} ${local.File_Repository} ${local.dis_server_started_msg}"
  tags            = local.tags
}

module "Central_Management" {
  source          = "../modules/service-alarms/"
  service_name    = "Central_Management"
  alarm_name      = "${local.environment_name}__Central_Management"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.Central_Management} ${local.dis_server_stopped_msg}"
  log_group_name  = local.log_group_name
  metric_name     = "CentralManagement"
  pattern_ok      = "${local.include_log_level} ${local.Central_Management} ${local.dis_server_started_msg}"
  tags            = local.tags
}

module "Job_Server" {
  source          = "../modules/service-alarms/"
  service_name    = "Job_Server"
  alarm_name      = "${local.environment_name}__Job_Server"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} ${local.Job_Server} ${local.dis_server_stopped_msg}"
  log_group_name  = local.log_group_name
  metric_name     = "JobServer"
  pattern_ok      = "${local.include_log_level} ${local.Job_Server} ${local.dis_server_started_msg}"
  tags            = local.tags
}

module "AdaptiveProcessingServer" {
  source          = "../modules/service-alarms/"
  service_name    = local.AdaptiveProcessingServer
  alarm_name      = "${local.environment_name}__${local.AdaptiveProcessingServer}"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} NDLDIS101.${local.AdaptiveProcessingServer} ${local.stopped_with_exit_code}"
  log_group_name  = local.log_group_name
  metric_name     = local.AdaptiveProcessingServer
  pattern_ok      = "${local.include_log_level} NDLDIS101.${local.AdaptiveProcessingServer} ${local.started_message}"
  tags            = local.tags
}

module "EIMAdaptiveProcessingServer" {
  source          = "../modules/service-alarms/"
  service_name    = local.EIMAdaptiveProcessingServer
  alarm_name      = "${local.environment_name}__${local.EIMAdaptiveProcessingServer}"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} NDLDIS101.${local.EIMAdaptiveProcessingServer} ${local.stopped_with_exit_code}"
  log_group_name  = local.log_group_name
  metric_name     = local.EIMAdaptiveProcessingServer
  pattern_ok      = "${local.include_log_level} NDLDIS101.${local.EIMAdaptiveProcessingServer} ${local.started_message}"
  tags            = local.tags
}

module "DataServices" {
  source          = "../modules/service-alarms/"
  service_name    = local.DataServices
  alarm_name      = "${local.environment_name}__${local.DataServices}"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.include_log_level} In ServiceStop"
  log_group_name  = local.log_group_name
  metric_name     = local.DataServices
  pattern_ok      = "${local.include_log_level} In ServiceStart"
  tags            = local.tags
}

module "etl" {
  source          = "../modules/service-alarms/"
  service_name    = "ETL"
  alarm_name      = "${local.environment_name}__ETL"
  name_space      = local.name_space
  host            = local.host_dis1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.ETL} Service stopped unexpectedly."
  log_group_name  = local.log_group_name
  metric_name     = "01CentralManagementServer"
  pattern_ok      = "${local.include_log_level} ${local.ETL} ${local.started_message}"
  tags            = local.tags
}
