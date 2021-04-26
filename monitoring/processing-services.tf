### Terraform modules ###
locals {
  #BPS1 VARS
  host_bps1                                   = "ndl-bps-${local.nart_prefix}1"
  PROCTIER001_WebIntelligenceProcessingServer = "PROCTIER001.WebIntelligenceProcessingServer"
  PROCTIER001_AdaptiveJobServer               = "PROCTIER001.AdaptiveJobServer"
  PROCTIER001_APS_Webi                        = "PROCTIER001.APS.Webi"
  PROCTIER001_ConnectionServer                = "PROCTIER001.ConnectionServer"
  PROCTIER001_ConnectionServer32              = "PROCTIER001.ConnectionServer32"

  #BPS2 VARS
  host_bps2                                   = "ndl-bps-${local.nart_prefix}2"
  PROCTIER002_WebIntelligenceProcessingServer = "PROCTIER002.WebIntelligenceProcessingServer"
  PROCTIER002_AdaptiveJobServer               = "PROCTIER002.AdaptiveJobServer"
  PROCTIER002_APS_Webi                        = "PROCTIER002.APS.Webi"
  PROCTIER002_ConnectionServer                = "PROCTIER002.ConnectionServer"
  PROCTIER002_ConnectionServer32              = "PROCTIER002.ConnectionServer32"

  #BPS3 VARS
  host_bps3                                   = "ndl-bps-${local.nart_prefix}3"
  PROCTIER003_WebIntelligenceProcessingServer = "PROCTIER003.WebIntelligenceProcessingServer"
  PROCTIER003_AdaptiveJobServer               = "PROCTIER003.AdaptiveJobServer"
  PROCTIER003_APS_Webi                        = "PROCTIER003.APS.Webi"
  PROCTIER003_ConnectionServer                = "PROCTIER003.ConnectionServer"
  PROCTIER003_ConnectionServer32              = "PROCTIER003.ConnectionServer32"
}

################################################
#
#            ALARMS BPS1
#
################################################
module "PROCTIER001_WebIntelligenceProcessingServer" {
  source          = "../modules/service-alarms/"
  service_name    = local.PROCTIER001_WebIntelligenceProcessingServer
  alarm_name      = "${local.environment_name}__${local.PROCTIER001_WebIntelligenceProcessingServer}"
  name_space      = local.name_space
  host            = local.host_bps1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER001_WebIntelligenceProcessingServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER001WebIntelligenceProcessingServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER001_WebIntelligenceProcessingServer} ${local.started_message}"
  alarm_threshold = "3"
  tags            = local.tags
}

module "PROCTIER001_AdaptiveJobServer" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER001_AdaptiveJobServer"
  alarm_name      = "${local.environment_name}__${local.PROCTIER001_AdaptiveJobServer}"
  name_space      = local.name_space
  host            = local.host_bps1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER001_AdaptiveJobServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER001AdaptiveJobServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER001_AdaptiveJobServer} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER001_APS_Webi" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER001_APS_Webi"
  alarm_name      = "${local.environment_name}__${local.PROCTIER001_APS_Webi}"
  name_space      = local.name_space
  host            = local.host_bps1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER001_APS_Webi}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER001APSWebi"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER001_APS_Webi} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER001_ConnectionServer" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER001_ConnectionServer"
  alarm_name      = "${local.environment_name}__${local.PROCTIER001_ConnectionServer}"
  name_space      = local.name_space
  host            = local.host_bps1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER001_ConnectionServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER001ConnectionServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER001_ConnectionServer} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER001_ConnectionServer32" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER001_ConnectionServer32"
  alarm_name      = "${local.environment_name}__${local.PROCTIER001_ConnectionServer32}"
  name_space      = local.name_space
  host            = local.host_bps1
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER001_ConnectionServer32}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER001ConnectionServer32"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER001_ConnectionServer32} ${local.started_message}"
  tags            = local.tags
}

################################################
#
#            ALARMS BPS2
#
################################################
module "PROCTIER002_WebIntelligenceProcessingServer" {
  source          = "../modules/service-alarms/"
  service_name    = local.PROCTIER002_WebIntelligenceProcessingServer
  alarm_name      = "${local.environment_name}__${local.PROCTIER002_WebIntelligenceProcessingServer}"
  name_space      = local.name_space
  host            = local.host_bps2
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER002_WebIntelligenceProcessingServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER002WebIntelligenceProcessingServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER002_WebIntelligenceProcessingServer} ${local.started_message}"
  alarm_threshold = "3"
  tags            = local.tags
}

module "PROCTIER002_AdaptiveJobServer" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER002_AdaptiveJobServer"
  alarm_name      = "${local.environment_name}__${local.PROCTIER002_AdaptiveJobServer}"
  name_space      = local.name_space
  host            = local.host_bps2
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER002_AdaptiveJobServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER002AdaptiveJobServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER002_AdaptiveJobServer} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER002_APS_Webi" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER002_APS_Webi"
  alarm_name      = "${local.environment_name}__${local.PROCTIER002_APS_Webi}"
  name_space      = local.name_space
  host            = local.host_bps2
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER002_APS_Webi}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER002APSWebi"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER002_APS_Webi} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER002_ConnectionServer" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER002_ConnectionServer"
  alarm_name      = "${local.environment_name}__${local.PROCTIER002_ConnectionServer}"
  name_space      = local.name_space
  host            = local.host_bps2
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER002_ConnectionServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER002ConnectionServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER002_ConnectionServer} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER002_ConnectionServer32" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER002_ConnectionServer32"
  alarm_name      = "${local.environment_name}__${local.PROCTIER002_ConnectionServer32}"
  name_space      = local.name_space
  host            = local.host_bps2
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER002_ConnectionServer32}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER002ConnectionServer32"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER002_ConnectionServer32} ${local.started_message}"
  tags            = local.tags
}

################################################
#
#            ALARMS BPS3
#
################################################
module "PROCTIER003_WebIntelligenceProcessingServer" {
  source          = "../modules/service-alarms/"
  service_name    = local.PROCTIER003_WebIntelligenceProcessingServer
  alarm_name      = "${local.environment_name}__${local.PROCTIER003_WebIntelligenceProcessingServer}"
  name_space      = local.name_space
  host            = local.host_bps3
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER003_WebIntelligenceProcessingServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER003WebIntelligenceProcessingServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER003_WebIntelligenceProcessingServer} ${local.started_message}"
  alarm_threshold = "3"
  tags            = local.tags
}

module "PROCTIER003_AdaptiveJobServer" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER003_AdaptiveJobServer"
  alarm_name      = "${local.environment_name}__${local.PROCTIER003_AdaptiveJobServer}"
  name_space      = local.name_space
  host            = local.host_bps3
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER003_AdaptiveJobServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER003AdaptiveJobServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER003_AdaptiveJobServer} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER003_APS_Webi" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER003_APS_Webi"
  alarm_name      = "${local.environment_name}__${local.PROCTIER003_APS_Webi}"
  name_space      = local.name_space
  host            = local.host_bps3
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER003_APS_Webi}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER003APSWebi"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER003_APS_Webi} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER003_ConnectionServer" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER003_ConnectionServer"
  alarm_name      = "${local.environment_name}__${local.PROCTIER003_ConnectionServer}"
  name_space      = local.name_space
  host            = local.host_bps3
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER003_ConnectionServer}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER003ConnectionServer"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER003_ConnectionServer} ${local.started_message}"
  tags            = local.tags
}

module "PROCTIER003_ConnectionServer32" {
  source          = "../modules/service-alarms/"
  service_name    = "PROCTIER003_ConnectionServer32"
  alarm_name      = "${local.environment_name}__${local.PROCTIER003_ConnectionServer32}"
  name_space      = local.name_space
  host            = local.host_bps3
  mis_team_action = local.mis_team_action
  alarm_actions   = aws_sns_topic.alarm_notification.arn
  pattern         = "${local.exclude_log_level} ${local.PROCTIER003_ConnectionServer32}"
  log_group_name  = local.log_group_name
  metric_name     = "PROCTIER003ConnectionServer32"
  pattern_ok      = "${local.include_log_level} ${local.PROCTIER003_ConnectionServer32} ${local.started_message}"
  tags            = local.tags
}
