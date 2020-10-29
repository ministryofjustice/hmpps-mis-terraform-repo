####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################
locals {
  common_name             = var.common_name
  tags                    = var.tags
  s3-config-bucket        = var.s3-config-bucket
  artefact-bucket         = var.artefact-bucket
  s3_oracledb_backups_arn = var.s3_oracledb_backups_arn
  s3_ssm_ansible_arn      = var.s3_ssm_ansible_arn
  delius-deps-bucket      = var.delius-deps-bucket
  migration-bucket        = var.migration-bucket
  region                  = var.region
  account_id              = var.account_id
}

############################################
# CREATE IAM POLICIES
############################################

#-------------------------------------------------------------
### INTERNAL IAM POLICES FOR EC2 RUNNING ECS SERVICES
#-------------------------------------------------------------

data "template_file" "iam_policy_app_int" {
  template = var.ec2_internal_policy_file

  vars = {
    s3-config-bucket        = local.s3-config-bucket
    s3-artefact-bucket      = local.artefact-bucket
    s3_oracledb_backups_arn = local.s3_oracledb_backups_arn
    s3_ssm_ansible_arn      = local.s3_ssm_ansible_arn
    delius-deps-bucket      = local.delius-deps-bucket
    migration-bucket        = local.migration-bucket
    app_role_arn            = module.create-iam-app-role-int.iamrole_arn
    runtime_role            = var.runtime_role
    ssm_prefix              = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${local.common_name}*"
  }
}

module "create-iam-app-role-int" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/role?ref=terraform-0.12"
  rolename   = "${local.common_name}-ec2"
  policyfile = var.ec2_policy_file
}

module "create-iam-instance-profile-int" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/instance_profile?ref=terraform-0.12"
  role   = module.create-iam-app-role-int.iamrole_name
}

module "create-iam-app-policy-int" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/rolepolicy?ref=terraform-0.12"
  policyfile = data.template_file.iam_policy_app_int.rendered
  rolename   = module.create-iam-app-role-int.iamrole_name
}

