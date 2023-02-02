locals {
  environment_identifier              = data.terraform_remote_state.common.outputs.short_environment_identifier
  app_name                            = data.terraform_remote_state.common.outputs.mis_app_name
  lambda_name                         = "${local.app_name}-modify-ec2-instance-type"
  lambda_notify_slack_name            = "${local.app_name}-scheduler-notify-ndmis-slack"
  tags                                = data.terraform_remote_state.common.outputs.common_tags
  account_id                          = data.terraform_remote_state.common.outputs.common_account_id
  resizing_scheduler_log_group        = "/aws/lambda/mis-modify-ec2-instance-type"
  enable_resizing_schedule            = var.mis_overide_resizing_schedule_tags
  dis_instance_type_am                = var.dis_instance_type_lower
  dis_instance_type_pm                = var.dis_instance_type
  slack_token_name                    = data.terraform_remote_state.monitoring.outputs.slack_token_name
  slack_nonprod_channel               = "ndmis-non-prod-alerts"
  slack_prod_channel                  = "ndmis-alerts"
}