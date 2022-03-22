locals {
  environment_identifier              = data.terraform_remote_state.common.outputs.short_environment_identifier
  mis_app_name                        = data.terraform_remote_state.common.outputs.mis_app_name
  bws_lb_name                         = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_elb_name
  bws_elb_arn_suffix                  = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_elb_arn_suffix
  nextcloud_lb_name                   = data.terraform_remote_state.nextcloud.outputs.nextcloud_lb_name
  samba_lb_name                       = data.terraform_remote_state.nextcloud.outputs.samba_lb_name
  log_group_name                      = "/mis/application_logs"
  name_space                          = "LogMetrics"
  exclude_log_level                   = "-INFORMATION -WARNING"
  include_log_level                   = "INFORMATION"
  mis_team_action                     = "If no OK alarm is received in a few minutes, please contact the MIS Team"
  nart_role                           = data.terraform_remote_state.common.outputs.legacy_environment_name
  nart_prefix                         = substr(local.nart_role, 0, length(local.nart_role) - 1)
  started_message                     = "has been started"
  name_prefix                         = var.short_environment_name
  tags                                = data.terraform_remote_state.common.outputs.common_tags
  account_id                          = data.terraform_remote_state.common.outputs.common_account_id
  target_group_arn_suffix             = data.terraform_remote_state.ec2-ndl-bws.outputs.target_group_arn_suffix
  bws_lb_mgmt_pipeline_log_group_name = "/aws/codebuild/${var.environment_name}-${local.mis_app_name}-lb-rule-mgmt-build"
  bws_pipeline_failure_pattern        = "Phase BUILD State FAILED"
  slack_nonprod_channel               = "ndmis-non-prod-alerts"
  slack_prod_channel                  = "ndmis-alerts"
}

#dashboard

resource "aws_cloudwatch_dashboard" "mis" {
  dashboard_name = "mis-${var.environment_type}-monitoring"
  dashboard_body = data.template_file.dashboard-body.rendered
}

### Log Group
resource "aws_cloudwatch_log_group" "mis_application_log_group" {
  name              = "/mis/application_logs"
  retention_in_days = var.cloudwatch_log_retention
  tags = merge(
    local.tags,
    {
      "Name" = "${local.name_prefix}-offapi-pri-cwl"
    },
  )
}

resource "aws_cloudwatch_log_group" "lb_mgmt" {
  name              = local.bws_lb_mgmt_pipeline_log_group_name
  retention_in_days = var.cloudwatch_log_retention
  tags = merge(
    local.tags,
    {
      "Name" = local.bws_lb_mgmt_pipeline_log_group_name
    },
  )
}

### SNS

resource "aws_sns_topic" "alarm_notification" {
  name = "${local.mis_app_name}-alarm-notification"
}

resource "aws_sns_topic_subscription" "alarm_subscription" {
  count     = var.mis_alarms_enabled == "true" ? 1 : 0
  topic_arn = aws_sns_topic.alarm_notification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notify-ndmis-slack.arn
}

### Lambda

locals {
  lambda_name = "${local.mis_app_name}-notify-ndmis-slack"
}

resource "aws_lambda_function" "notify-ndmis-slack" {
  filename         = data.archive_file.notify-ndmis-slack.output_path
  function_name    = local.lambda_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "${local.lambda_name}.handler"
  source_code_hash = filebase64sha256(data.archive_file.notify-ndmis-slack.output_path)
  runtime          = "nodejs12.x"
  
  environment {
    variables = {
      REGION            = var.region
      ENVIRONMENT_TYPE  = var.environment_type
      SLACK_TOKEN       = aws_ssm_parameter.slack_token.name    
      SLACK_CHANNEL     = var.environment_type == "prod" ? local.slack_prod_channel : local.slack_nonprod_channel
    }
  }
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify-ndmis-slack.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_notification.arn
}

