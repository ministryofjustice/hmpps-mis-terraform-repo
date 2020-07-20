### Terraform modules ###
locals {
#BCS1 VARS
  host_bcs1                                   = "ndl-bcs-${local.nart_prefix}1"
  CMSTIER001_APS_Core                         = "CMSTIER001_APS_Core"
  CMSTIER001_APS_PromotionManager		          = "CMSTIER001.APS.PromotionManager"
  CMSTIER001_CentralManagementServer          =	"CMSTIER001.CentralManagementServer"
  CMSTIER001_ConnectionServer				          = "CMSTIER001.ConnectionServer"
  CMSTIER001_ConnectionServer32			          = "CMSTIER001.ConnectionServer32"
  CMSTIER001_EventServer		                  = "CMSTIER001.EventServer"
  CMSTIER001_InputFilerepository	            = "CMSTIER001.InputFilerepository"
  CMSTIER001_OutputFilerepository	            = "CMSTIER001.OutputFilerepository"

#BCS2 VARS
  host_bcs2                                   = "ndl-bcs-${local.nart_prefix}2"
  CMSTIER002_CentralManagementServer          =	"CMSTIER002.CentralManagementServer"
  CMSTIER002_ConnectionServer				          = "CMSTIER002.ConnectionServer"
  CMSTIER002_ConnectionServer32			          = "CMSTIER002.ConnectionServer32"
  CMSTIER002_APS_Search	                      = "CMSTIER002.APS.Search"

#BCS3 VARS
  host_bcs3                                   = "ndl-bcs-${local.nart_prefix}3"
  CMSTIER003_APS_Core                         = "CMSTIER003.APS.Core"
  CMSTIER003_APS_MonitoringService            = "CMSTIER003.APS.MonitoringService"
  CMSTIER003_CentralManagementServer          =	"CMSTIER003.CentralManagementServer"
  CMSTIER003_ConnectionServer				          = "CMSTIER003.ConnectionServer"
  CMSTIER003_ConnectionServer32			          = "CMSTIER003.ConnectionServer32"
  CMSTIER003_WebApplicationContainerServer    = "CMSTIER003.WebApplicationContainerServer"
}


################################################
#
#            ALARMS BCS1
#
################################################
module "CMSTIER001_APS_Core" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER001_APS_Core}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER001_APS_Core}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER001_APS_Core}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER001APSPromotionManager"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER001_APS_Core} ${local.started_message}"
}


module "CMSTIER001_APS_PromotionManager" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER001_APS_PromotionManager}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER001_APS_PromotionManager}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER001_APS_PromotionManager}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER001APSCore"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER001_APS_PromotionManager} ${local.started_message}"
}


module "CMSTIER001_CentralManagementServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER001_CentralManagementServer}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER001_CentralManagementServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER001_CentralManagementServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER001CentralManagementServer"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER001_CentralManagementServer} ${local.started_message}"
}

module "CMSTIER001_ConnectionServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER001_ConnectionServer}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER001_ConnectionServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER001_ConnectionServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER001ConnectionServer"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER001_ConnectionServer} ${local.started_message}"
}

module "CMSTIER001_ConnectionServer32" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER001_ConnectionServer32}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER001_ConnectionServer32}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER001_ConnectionServer32}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER001ConnectionServer32"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER001_ConnectionServer32} ${local.started_message}"
}


module "CMSTIER001_EventServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER001_EventServer}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER001_EventServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER001_EventServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER001EventServer"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER001_EventServer} ${local.started_message}"
}


module "CMSTIER001_InputFilerepository" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER001_InputFilerepository}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER001_InputFilerepository}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER001_InputFilerepository}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER001InputFilerepository"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER001_InputFilerepository} ${local.started_message}"
}


module "CMSTIER001_OutputFilerepository" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER001_OutputFilerepository}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER001_OutputFilerepository}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER001_OutputFilerepository}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER001OutputFilerepository"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER001_OutputFilerepository} ${local.started_message}"
}

################################################
#
#            ALARMS BCS2
#
################################################

module "CMSTIER002_CentralManagementServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER002_CentralManagementServer}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER002_CentralManagementServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs2}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER002_CentralManagementServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER002CentralManagementServer"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER002_CentralManagementServer} ${local.started_message}"
}


module "CMSTIER002_ConnectionServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER002_ConnectionServer}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER002_ConnectionServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs2}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER002_ConnectionServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER002ConnectionServer"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER002_ConnectionServer} ${local.started_message}"
}

module "CMSTIER002_ConnectionServer32" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER002_ConnectionServer32}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER002_ConnectionServer32}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs2}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER002_ConnectionServer32}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER002ConnectionServer32"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER002_ConnectionServer32} ${local.started_message}"
}


module "CMSTIER002_APS_Search" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER002_APS_Search}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER002_APS_Search}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs2}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER002_APS_Search}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER002APSSearch"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER002_APS_Search} ${local.started_message}"
}


################################################
#
#            ALARMS BCS3
#
################################################
module "CMSTIER003_APS_Core" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER003_APS_Core}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER003_APS_Core}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs3}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER003_APS_Core}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER003APSPromotionManager"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER003_APS_Core} ${local.started_message}"
}


module "CMSTIER003_CentralManagementServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER003_CentralManagementServer}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER003_CentralManagementServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs3}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER003_CentralManagementServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER003CentralManagementServer"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER003_CentralManagementServer} ${local.started_message}"
}

module "CMSTIER003_ConnectionServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER003_ConnectionServer}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER003_ConnectionServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs3}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER003_ConnectionServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER003ConnectionServer"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER003_ConnectionServer} ${local.started_message}"
}

module "CMSTIER003_ConnectionServer32" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER003_ConnectionServer32}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER003_ConnectionServer32}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs3}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER003_ConnectionServer32}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER003ConnectionServer32"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER003_ConnectionServer32} ${local.started_message}"
}

module "CMSTIER003_APS_MonitoringService" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER003_APS_MonitoringService}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER003_APS_MonitoringService}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs3}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER003_APS_MonitoringService}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER003APSMonitoringService"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER003_APS_MonitoringService} ${local.started_message}"
}

module "CMSTIER003_WebApplicationContainerServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.CMSTIER003_WebApplicationContainerServer}"
  alarm_name                     = "${local.environment_name}__${local.CMSTIER003_WebApplicationContainerServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bcs3}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.CMSTIER003_WebApplicationContainerServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "CMSTIER003WebApplicationContainerServer"
  pattern_ok                     = "${local.include_log_level} ${local.CMSTIER003_WebApplicationContainerServer} ${local.started_message}"
}
