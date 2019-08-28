####################################################
# EFS
####################################################
module "efs_share" {
  source                 = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//efs"
  environment_identifier = "${local.short_environment_identifier}"
  tags                   = "${local.tags}"
  encrypted              = true
  performance_mode       = "generalPurpose"
  throughput_mode        = "bursting"
  share_name             = "nextcloud-efs-share"
  zone_id                = "${local.private_zone_id}"
  domain                 = "${local.internal_domain}"
  subnets                = "${local.private_subnet_ids}"
  security_groups        = ["${local.efs_security_groups}"]
}
