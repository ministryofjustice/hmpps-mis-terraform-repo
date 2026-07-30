####################################################
# EFS
####################################################
module "efs_share" {
  source                 = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/efs?ref=terraform-0.12"
  environment_identifier = local.short_environment_identifier
  tags                   = local.tags
  encrypted              = true
  performance_mode       = "generalPurpose"
  throughput_mode        = "bursting"
  share_name             = "nextcloud-efs-share"
  zone_id                = local.private_zone_id
  domain                 = local.internal_domain
  subnets                = local.private_subnet_ids
  security_groups        = [local.efs_security_groups]
}

data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "efs_share" {
  statement {
    sid    = "SameAccountNFSv4Access"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]

    resources = [module.efs_share.efs_arn]
  }
  statement {
    sid    = "CrossAccountIAMAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.nextcloud_efs_iam_mount_principals
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]

    resources = [module.efs_share.efs_arn]

    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "efs_share" {
  file_system_id = module.efs_share.efs_id
  policy         = data.aws_iam_policy_document.efs_share.json
}

resource "aws_efs_access_point" "efs_share_modernisation_platform_access" {
  file_system_id = module.efs_share.efs_id

  posix_user {
    gid            = 48
    uid            = 48
    secondary_gids = []
  }

  root_directory {
    path = "/${var.environment_name}-mis-nextcloud/files/shared_files"
  }

  tags = merge(local.tags, {
    Name = "${local.short_environment_identifier}-nextcloud-efs-share-modernisation-platform-access"
  })
}
