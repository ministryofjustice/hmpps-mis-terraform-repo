### Terraform modules ###
locals {
  host_bps1                                   = "${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[0]}"
  started_message                             = "has been started"
  PROCTIER001_WebIntelligenceProcessingServer = "PROCTIER001.WebIntelligenceProcessingServer"
  PROCTIER001_AdaptiveJobServer               = "PROCTIER001.AdaptiveJobServer"
  PROCTIER001_APS_Webi                        = "PROCTIER001.APS.Webi"
  PROCTIER001_ConnectionServer                = "PROCTIER001.ConnectionServer"
  PROCTIER001_ConnectionServer32              = "PROCTIER001.ConnectionServer32"
}

################################################
#
#            ALARMS BPS1
#
################################################
module "PROCTIER001_WebIntelligenceProcessingServer" {
  source                         = "modules/service-alarms/"
  service_name                   = "${local.PROCTIER001_WebIntelligenceProcessingServer}"
  alarm_name                     = "${local.environment_name}__${local.PROCTIER001_WebIntelligenceProcessingServer}"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bps1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.PROCTIER001_WebIntelligenceProcessingServer}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "PROCTIER001WebIntelligenceProcessingServer"
  pattern_ok                     = "${local.include_log_level} ${local.PROCTIER001_WebIntelligenceProcessingServer} ${local.started_message}"
}


#module "PROCTIER001_AdaptiveJobServer" {
#  source                         = "modules/service-alarms/"
#  service_name                   = "PROCTIER001_AdaptiveJobServer"
#  alarm_name                     = "${local.environment_name}__${local.PROCTIER001_AdaptiveJobServer}__critical"
#  name_space                     = "${local.name_space}"
#  host                           = "${local.host_bps1}"
#  mis_team_action                = "${local.mis_team_action}"
#  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
#  pattern                        = "${local.exclude_log_level} ${local.PROCTIER001_AdaptiveJobServer}"
#  log_group_name                 = "${local.log_group_name}"
#  metric_name                    = "PROCTIER001AdaptiveJobServer"
#  pattern_ok                     = "${local.include_log_level} ${local.PROCTIER001_AdaptiveJobServer} ${local.started_message}"
#}
#
#
#module "PROCTIER001_APS_Webi" {
#  source                         = "modules/service-alarms/"
#  service_name                   = "PROCTIER001_APS_Webi"
#  alarm_name                     = "${local.environment_name}__${local.PROCTIER001_APS_Webi}__critical"
#  name_space                     = "${local.name_space}"
#  host                           = "${local.host_bps1}"
#  mis_team_action                = "${local.mis_team_action}"
#  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
#  pattern                        = "${local.exclude_log_level} ${local.PROCTIER001_APS_Webi}"
#  log_group_name                 = "${local.log_group_name}"
#  metric_name                    = "PROCTIER001APSWebi"
#  pattern_ok                     = "${local.include_log_level} ${local.PROCTIER001_APS_Webi} ${local.started_message}"
#}
#
#
#module "PROCTIER001_ConnectionServer" {
#  source                         = "modules/service-alarms/"
#  service_name                   = "PROCTIER001_ConnectionServer"
#  alarm_name                     = "${local.environment_name}__${local.PROCTIER001_ConnectionServer}__critical"
#  name_space                     = "${local.name_space}"
#  host                           = "${local.host_bps1}"
#  mis_team_action                = "${local.mis_team_action}"
#  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
#  pattern                        = "${local.exclude_log_level} ${local.PROCTIER001_ConnectionServer}"
#  log_group_name                 = "${local.log_group_name}"
#  metric_name                    = "PROCTIER001APSWebi"
#  pattern_ok                     = "${local.include_log_level} ${local.PROCTIER001_ConnectionServer} ${local.started_message}"
#}
#
#module "PROCTIER001_ConnectionServer32" {
#  source                         = "modules/service-alarms/"
#  service_name                   = "PROCTIER001_ConnectionServer32"
#  alarm_name                     = "${local.environment_name}__${local.PROCTIER001_ConnectionServer32}__critical"
#  name_space                     = "${local.name_space}"
#  host                           = "${local.host_bps1}"
#  mis_team_action                = "${local.mis_team_action}"
#  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
#  pattern                        = "${local.exclude_log_level} ${local.PROCTIER001_ConnectionServer32}"
#  log_group_name                 = "${local.log_group_name}"
#  metric_name                    = "PROCTIER001ConnectionServer32"
#  pattern_ok                     = "${local.include_log_level} ${local.PROCTIER001_ConnectionServer32} ${local.started_message}"
#}
