terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/common/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the s3bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3buckets" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/s3buckets/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the oracledb backup s3 bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3-oracledb-backups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "s3/oracledb-backups/terraform.tfstate"
    region = var.region
  }
}

####################################################
# Locals
####################################################

locals {
  region                  = var.region
  common_name             = data.terraform_remote_state.common.outputs.common_name
  tags                    = data.terraform_remote_state.common.outputs.common_tags
  s3-config-bucket        = data.terraform_remote_state.common.outputs.common_s3-config-bucket
  artefact-bucket         = data.terraform_remote_state.s3buckets.outputs.s3bucket
  delius-deps-bucket      = substr(var.dependencies_bucket_arn, 13, -1) # name (cut arn off - then insert name into arn in template??)
  migration-bucket        = substr(var.migration_bucket_arn, 13, -1)    # name
  s3_oracledb_backups_arn = data.terraform_remote_state.s3-oracledb-backups.outputs.s3_oracledb_backups.arn
  runtime_role            = var.cross_account_iam_role
  account_id              = data.terraform_remote_state.common.outputs.common_account_id
}

####################################################
# IAM - Application Specific
####################################################
module "iam" {
  source                   = "../modules/iam"
  common_name              = "${local.common_name}-infra"
  tags                     = local.tags
  ec2_policy_file          = "ec2_policy.json"
  ec2_internal_policy_file = file("../policies/ec2_internal_policy.json")
  s3-config-bucket         = local.s3-config-bucket
  artefact-bucket          = local.artefact-bucket
  runtime_role             = local.runtime_role
  region                   = local.region
  account_id               = local.account_id
}

####################################################
# IAM - Application Specific LDAP
####################################################
module "ldap" {
  source                   = "../modules/iam"
  common_name              = "${local.common_name}-ldap"
  tags                     = local.tags
  ec2_policy_file          = "ec2_policy.json"
  ec2_internal_policy_file = file("../policies/ec2_ldap_policy.json")
  s3-config-bucket         = local.s3-config-bucket
  artefact-bucket          = local.artefact-bucket
  region                   = local.region
  account_id               = local.account_id
}

####################################################
# IAM - Application Specific
####################################################
module "jumphost" {
  source                   = "../modules/iam"
  common_name              = "${local.common_name}-jumphost"
  tags                     = local.tags
  ec2_policy_file          = "ec2_policy.json"
  ec2_internal_policy_file = file("../policies/ec2_jumphost_policy.json")
  s3-config-bucket         = local.s3-config-bucket
  artefact-bucket          = local.artefact-bucket
  region                   = local.region
  account_id               = local.account_id
}

####################################################
# IAM - Application Specific
####################################################
module "mis_db" {
  source                   = "../modules/iam"
  common_name              = "${local.common_name}-mis-db"
  tags                     = local.tags
  ec2_policy_file          = "ec2_policy.json"
  ec2_internal_policy_file = file("../policies/ec2_mis_db_policy.json")
  s3-config-bucket         = local.s3-config-bucket
  artefact-bucket          = local.artefact-bucket
  s3_oracledb_backups_arn  = local.s3_oracledb_backups_arn
  delius-deps-bucket       = local.delius-deps-bucket
  migration-bucket         = local.migration-bucket
  runtime_role             = local.runtime_role
  region                   = local.region
  account_id               = local.account_id
}

####################################################
# IAM - EC2 Backups
####################################################

data "template_file" "backup_assume_role_template" {
  template = file("../policies/backup_assume_role.tpl")
  vars     = {}
}

resource "aws_iam_role" "mis_ec2_backup_role" {
  name               = "${local.common_name}-mis-ec2-bkup-pri-iam"
  assume_role_policy = data.template_file.backup_assume_role_template.rendered
}

resource "aws_iam_role_policy_attachment" "mis_ec2_backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.mis_ec2_backup_role.name
}

resource "aws_iam_role_policy_attachment" "mis_ec2_restore_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.mis_ec2_backup_role.name
}

resource "aws_iam_role_policy_attachment" "mis_ec2_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupFullAccess"
  role       = aws_iam_role.mis_ec2_backup_role.name
}

resource "aws_iam_role_policy_attachment" "mis_ec2_passrole_policy" {
  policy_arn = aws_iam_policy.mis_ec2_passrole.arn
  role       = aws_iam_role.mis_ec2_backup_role.name
}

resource "aws_iam_policy" "mis_ec2_passrole" {
  name        = "${var.environment_type}-mis-aws-backup-pass-role-policy"
  path        = "/"
  description = "${var.environment_type}-mis-aws-backup-pass-role-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

