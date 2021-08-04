locals {
  ami_id                         = data.aws_ami.amazon_ami.id
  account_id                     = data.terraform_remote_state.common.outputs.common_account_id
  vpc_id                         = data.terraform_remote_state.common.outputs.vpc_id
  cidr_block                     = data.terraform_remote_state.common.outputs.vpc_cidr_block
  allowed_cidr_block             = [data.terraform_remote_state.common.outputs.vpc_cidr_block]
  internal_domain                = data.terraform_remote_state.common.outputs.internal_domain
  private_zone_id                = data.terraform_remote_state.common.outputs.private_zone_id
  external_domain                = data.terraform_remote_state.common.outputs.external_domain
  public_zone_id                 = data.terraform_remote_state.common.outputs.public_zone_id
  environment_identifier         = data.terraform_remote_state.common.outputs.environment_identifier
  short_environment_identifier   = data.terraform_remote_state.common.outputs.short_environment_identifier
  region                         = var.region
  app_name                       = data.terraform_remote_state.common.outputs.mis_app_name
  #environment                   = data.terraform_remote_state.common.outputs.environments
  private_subnet_map             = data.terraform_remote_state.common.outputs.private_subnet_map
  s3bucket                       = data.terraform_remote_state.s3bucket.outputs.s3bucket
  app_hostnames                  = data.terraform_remote_state.common.outputs.app_hostnames
  certificate_arn                = data.aws_acm_certificate.cert.arn
  public_cidr_block              = [data.terraform_remote_state.common.outputs.db_cidr_block]
  private_cidr_block             = [data.terraform_remote_state.common.outputs.private_cidr_block]
  db_cidr_block                  = [data.terraform_remote_state.common.outputs.db_cidr_block]
  sg_map_ids                     = data.terraform_remote_state.security-groups.outputs.sg_map_ids
  instance_profile               = data.terraform_remote_state.iam.outputs.iam_policy_int_app_instance_profile_name
  ssh_deployer_key               = data.terraform_remote_state.common.outputs.common_ssh_deployer_key
  nart_role                      = "ndl-dfi-${data.terraform_remote_state.common.outputs.legacy_environment_name}"
  standard_nart_role             = data.terraform_remote_state.common.outputs.legacy_environment_name
  standard_nart_prefix           = substr(local.standard_nart_role, 0, length(local.standard_nart_role) - 1)

  # Create a prefix that removes the final integer from the nart_role value
  nart_prefix                    = substr(local.nart_role, 0, length(local.nart_role) - 1)
  sg_outbound_id                 = data.terraform_remote_state.common.outputs.common_sg_outbound_id
  sg_smtp_ses                    = data.terraform_remote_state.security-groups_secondary.outputs.sg_smtp_ses
  dfi_port                       = data.terraform_remote_state.security-groups.outputs.bws_port
  public_subnet_ids              = flatten([data.terraform_remote_state.common.outputs.public_subnet_ids])
  logs_bucket                    = data.terraform_remote_state.common.outputs.common_s3_lb_logs_bucket
  tags                           = data.terraform_remote_state.common.outputs.common_tags
  config_bucket                  = data.terraform_remote_state.common.outputs.common_s3-config-bucket

   #FSx Filesytem integration via Security Group membership
  fsx_integration_security_group = data.terraform_remote_state.fsx-integration.outputs.mis_fsx_integration_security_group

  dfi_disable_api_termination    = var.dfi_disable_api_termination
  dfi_ebs_optimized              = var.dfi_ebs_optimized
  dfi_hibernation                = var.dfi_hibernation

  verification_error_pattern     = "Verification failed"
  error_pattern                  = "WARN Failed"
  creds_error_pattern            = "Volume did not receive creds for location"
  datasync_log_group             = aws_cloudwatch_log_group.s3_to_efs.name
  sns_topic_arn                  = data.terraform_remote_state.monitoring.outputs.sns_topic_arn
  name_space                     = "LogMetrics"
  dfi_instance_ids               = aws_instance.dfi_server.*.id
  dfi_primary_dns_ext            = aws_route53_record.dfi_dns_ext.*.fqdn
  dfi_ami_id                     = aws_instance.dfi_server.*.ami
  dfi_instance_type              = aws_instance.dfi_server.*.instance_type
  dfi_lb_name                    = element(concat(aws_elb.dfi.*.id, [""]), 0)
  dfi_lambda_log_group           = "/aws/lambda/dfi-lambda-function"
  dfi_lambda_error_pattern       = "Error processing request"
  match_all_patterns             = " "  #match all patterns
  dfi_etl_metric_name            = "DfiEtlErrorsCount"
  dfi_etl_log_group_name         = "/dfi/extraction/transformation/loading/log"
  host_dfi1                      = "${local.nart_prefix}1"
  pattern_host_name              = "NDLDFI${local.standard_nart_prefix}1"
  mis_team_action                = "If no OK alarm is received in a few minutes, please contact the MIS Team"
  log_group_name                 = "/mis/application_logs"
  include_log_level              = "INFORMATION"
  exclude_log_level              = "-INFORMATION -WARNING"
  started_message                = "has been started"
  dfi_pipeline_failure_pattern   = "Phase BUILD State FAILED"
  dfi_pipeline_log_group_name    = "/aws/codebuild/${var.environment_name}-dfi-s3-fsx-build"

  #Overide autostop tag
  overide_tags = merge(
    local.tags,
    {
      "autostop-${var.environment_type}" = var.mis_overide_autostop_tags
    },
  )
}
