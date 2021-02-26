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
  s3_ssm_ansible_arn       = local.s3_ssm_ansible_arn
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

resource "aws_iam_role_policy_attachment" "ssm_agent" {
  role       = module.mis_db.iam_policy_int_app_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = module.mis_db.iam_policy_int_app_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "template_file" "mis_ec2_ssm_parameterstore_read" {
  template = "${file("./ssm-paramstore-policy.tpl")}"

  vars = {
    account_number     = local.account_id
    environment_name   = local.environment_name
    application_name   = local.project_name
  }
}

# "Resource": "arn:aws:ssm:eu-west-2:{account_number}:parameter//${environment_name}/${application_name}/mis-activedirectory/ad/*"
# "Resource": "arn:aws:ssm:eu-west-2:479759138745:parameter//delius-mis-dev/delius/mis-activedirectory/ad/*"
resource "aws_iam_policy" "mis_ec2_ssm_parameterstore_read" {
  name        = "${var.environment_type}-mis-aws-ssm-policy"
  path        = "/"
  description = "${var.environment_type}-mis-aws-ssm-policy"
  policy      = data.template_file.mis_ec2_ssm_parameterstore_read.rendered
}

resource "aws_iam_role_policy_attachment" "mis_ec2_ssm_parameterstore_read" {
  role       = module.iam.iam_policy_int_app_role_name
  policy_arn = aws_iam_policy.mis_ec2_ssm_parameterstore_read.arn
}


# resource "aws_iam_policy" "mis_ec2_ssm_parameterstore_read" {
#   name        = "${var.environment_type}-mis-aws-backup-pass-role-policy"
#   path        = "/"
#   description = "${var.environment_type}-mis-aws-backup-pass-role-policy"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "VisualEditor0",
#             "Effect": "Allow",
#             "Action": "ssm:GetParametersByPath",
#             "Resource": "arn:aws:ssm:eu-west-2:479759138745:parameter//delius-mis-dev/delius/mis-activedirectory/ad/*"
#         }
#     ]
# }
# EOF

# }


# Windows Instances AD Autojoin policy
# https://aws.amazon.com/blogs/security/how-to-configure-your-ec2-instances-to-automatically-join-a-microsoft-active-directory-domain/

data "template_file" "AmazonEC2RoleforSSM_ASGDomainJoin" {
  template = "${file("../policies/AmazonEC2RoleforSSM-ASGDomainJoin.json")}"
}

resource "aws_iam_policy" "AmazonEC2RoleforSSM_ASGDomainJoin" {
  name        = "AmazonEC2RoleforSSM_ASGDomainJoin"
  path        = "/"
  description = "AmazonEC2RoleforSSM-ASGDomainJoin for Windows Instance AD Auto Join"
  policy      = data.template_file.AmazonEC2RoleforSSM_ASGDomainJoin.rendered
}

resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforSSM_ASGDomainJoin" {
  role       = module.iam.iam_policy_int_app_role_name
  policy_arn = aws_iam_policy.AmazonEC2RoleforSSM_ASGDomainJoin.arn
}