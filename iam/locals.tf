locals {
  region                  = var.region
  common_name             = data.terraform_remote_state.common.outputs.common_name
  tags                    = data.terraform_remote_state.common.outputs.common_tags
  s3-config-bucket        = data.terraform_remote_state.common.outputs.common_s3-config-bucket
  artefact-bucket         = data.terraform_remote_state.s3buckets.outputs.s3bucket
  delius-deps-bucket      = substr(var.dependencies_bucket_arn, 13, -1) # name (cut arn off - then insert name into arn in template??)
  migration-bucket        = substr(var.migration_bucket_arn, 13, -1)    # name
  s3_oracledb_backups_arn = data.terraform_remote_state.s3-oracledb-backups.outputs.s3_oracledb_backups.arn
  s3_ssm_ansible_arn      = data.terraform_remote_state.ci_common.outputs.ssm_ansible_bucket.arn
  runtime_role            = var.cross_account_iam_role
  account_id              = data.terraform_remote_state.common.outputs.common_account_id
  environment_name        = var.environment_name
  project_name            = var.project_name
}