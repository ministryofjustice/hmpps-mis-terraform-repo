### Terraform modules ###
locals {
#DIS ETL VARS
  host_dis1                                   = "ndl-dis-${local.nart_prefix}1"
  ETL                                         = "01.CentralManagementServer"
  httpd                                       = "httpd"
  host_bws                                    = "BWS Hosts"
  tomcat                                      = "tomcat"
}


################################################
#
#            ALARMS BWS HTTPD
#
################################################
module "bwshttpd" {
  source                         = "modules/service-alarms/"
  service_name                   = "httpd"
  alarm_name                     = "${local.environment_name}__BWS_Httpd"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bws}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.httpd}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "BwsHttpd"
  pattern_ok                     = "${local.include_log_level} ${local.httpd} ${local.started_message}"
}


################################################
#
#            ALARMS DIS1 ETL
#
################################################
module "bwstomcat" {
  source                         = "modules/service-alarms/"
  service_name                   = "tomcat"
  alarm_name                     = "${local.environment_name}__BWS_Tomcat"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_bws}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.tomcat}"
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "BwsTomcat"
  pattern_ok                     = "${local.include_log_level} ${local.tomcat} ${local.started_message}"
}



################################################
#
#            ALARMS DIS1 ETL
#
################################################
module "etl" {
  source                         = "modules/service-alarms/"
  service_name                   = "ETL"
  alarm_name                     = "${local.environment_name}__ETL"
  name_space                     = "${local.name_space}"
  host                           = "${local.host_dis1}"
  mis_team_action                = "${local.mis_team_action}"
  alarm_actions                  = "${aws_sns_topic.alarm_notification.arn}"
  pattern                        = "${local.exclude_log_level} ${local.ETL} Service stopped unexpectedly."
  log_group_name                 = "${local.log_group_name}"
  metric_name                    = "01CentralManagementServer"
  pattern_ok                     = "${local.include_log_level} ${local.ETL} ${local.started_message}"
}
