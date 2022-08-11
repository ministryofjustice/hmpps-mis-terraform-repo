locals {
  common_name = "${local.environment_identifier}-${local.app_name}"
  dns_name    = "${local.app_name}-db"
}

#-------------------------------------------------------------
### IAM ROLE FOR RDS
#-------------------------------------------------------------

module "rds_monitoring_role" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/role?ref=terraform-0.12"
  rolename   = "${local.common_name}-monitoring"
  policyfile = "rds_monitoring.json"
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = module.rds_monitoring_role.iamrole_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

############################################
# KMS KEY GENERATION - FOR ENCRYPTION
############################################

module "kms_key" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/kms?ref=terraform-0.12"
  kms_key_name = local.common_name
  tags         = local.tags
}

############################################
# CREATE DB SUBNET GROUP
############################################
module "db_subnet_group" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/rds/db_subnet_group?ref=terraform-0.12"
  create      = var.create_db_subnet_group
  identifier  = local.common_name
  name_prefix = "${local.common_name}-"
  subnet_ids  = local.private_subnet_ids
  tags        = local.tags
}

############################################
# CREATE PARAMETER GROUP
############################################
module "db_parameter_group" {
  source      = "../modules/db_parameter_group"
  create      = var.create_db_parameter_group
  identifier  = local.common_name
  name_prefix = "${local.common_name}-"
  family      = var.family
  parameters  = flatten(var.parameters)
  tags = local.tags
}

############################################
# CREATE DB OPTIONS
############################################
module "db_option_group" {
  source                   = "../modules/db_option_group"
  create                   = var.create_db_option_group
  identifier               = local.common_name
  name_prefix              = "${local.common_name}-"
  option_group_description = "${local.common_name} options group"
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version
  options                  = [var.options]
  tags                     = local.tags
}

############################################
# CREATE DB INSTANCE
############################################

module "db_instance" {
  source                              = "../modules/db_instance"
  identifier                          = local.common_name
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.rds_instance_class
  allocated_storage                   = var.rds_allocated_storage
  storage_type                        = var.storage_type
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = module.kms_key.kms_arn
  license_model                       = var.license_model
  name                                = local.app_name
  username                            = local.nextcloud_db_user
  password                            = aws_ssm_parameter.nextcloud_db_password.value
  port                                = var.port
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  replicate_source_db                 = var.replicate_source_db
  snapshot_identifier                 = var.snapshot_identifier

  vpc_security_group_ids = flatten([
    local.nextcloud_db_sg,
  ])

  db_subnet_group_name  = module.db_subnet_group.db_subnet_group_id
  parameter_group_name  = module.db_parameter_group.db_parameter_group_id
  option_group_name     = module.db_option_group.db_option_group_id
  multi_az              = var.multi_az
  iops                  = var.iops
  publicly_accessible   = var.publicly_accessible

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  final_snapshot_identifier   = "${local.common_name}-final-snapshot"

  backup_retention_period = var.mariadb_backup_retention_period
  backup_window           = var.backup_window

  monitoring_interval = var.mariadb_monitoring_interval
  monitoring_role_arn = module.rds_monitoring_role.iamrole_arn

  timezone           = var.timezone
  character_set_name = var.character_set_name

  tags = merge(local.tags,
    {
      "autostop-${var.environment_type}" = "Phase1"
    }
  )
}

###############################################
# Create route53 entry for mariadb
###############################################

resource "aws_route53_record" "mariadb_dns_entry" {
  name    = "${local.dns_name}.${local.internal_domain}"
  type    = "CNAME"
  zone_id = local.private_zone_id
  ttl     = 300
  records = [module.db_instance.db_instance_address]
}
