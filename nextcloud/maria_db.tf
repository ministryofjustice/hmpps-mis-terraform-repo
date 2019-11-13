
locals {
  common_name         = "${local.environment_identifier}-${local.app_name}"
  replica_common_name = "${local.common_name}-rpl"
  dns_name            = "${local.app_name}-db"
}

############################################
# KMS KEY GENERATION - FOR ENCRYPTION
############################################

module "kms_key" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//kms"
  kms_key_name = "${local.common_name}"
  tags         = "${local.tags}"
}

############################################
# CREATE DB SUBNET GROUP
############################################
module "db_subnet_group" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//rds//db_subnet_group"
  create      = "${var.create_db_subnet_group}"
  identifier  = "${local.common_name}"
  name_prefix = "${local.common_name}-"
  subnet_ids  = ["${local.private_subnet_ids}"]
  tags        = "${local.tags}"
}

############################################
# CREATE PARAMETER GROUP
############################################
module "db_parameter_group" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//rds//db_parameter_group"

  create      = "${var.create_db_parameter_group}"
  identifier  = "${local.common_name}"
  name_prefix = "${local.common_name}-"
  family      = "${var.family}"
  parameters = ["${var.parameters}"]

  tags = "${local.tags}"
}

############################################
# CREATE DB OPTIONS
############################################
module "db_option_group" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//rds//db_option_group"
  create                   = "${var.create_db_option_group}"
  identifier               = "${local.common_name}"
  name_prefix              = "${local.common_name}-"
  option_group_description = "${local.common_name} options group"
  engine_name              = "${var.engine}"
  major_engine_version     = "${var.major_engine_version}"

  options = ["${var.options}"]

  tags = "${local.tags}"
}

############################################
# CREATE DB INSTANCE
############################################

module "db_instance" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//rds//db_instance"

  create            = "${var.create_db_instance}"
  identifier        = "${local.common_name}"
  engine            = "${var.engine}"
  engine_version    = "${var.engine_version}"
  instance_class    = "${var.rds_instance_class}"
  allocated_storage = "${var.rds_allocated_storage}"
  storage_type      = "${var.storage_type}"
  storage_encrypted = "${var.storage_encrypted}"
  kms_key_id        = "${module.kms_key.kms_arn}"
  license_model     = "${var.license_model}"

  name                                = "${local.app_name}"
  username                            = "${local.nextcloud_db_user}"
  password                            = "${aws_ssm_parameter.nextcloud_db_password.value}"
  port                                = "${var.port}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"

  replicate_source_db = "${var.replicate_source_db}"

  snapshot_identifier = "${var.snapshot_identifier}"

  vpc_security_group_ids = [
    "${local.nextcloud_db_sg}",
  ]

  db_subnet_group_name = "${module.db_subnet_group.db_subnet_group_id}"
  parameter_group_name = "${module.db_parameter_group.db_parameter_group_id}"
  option_group_name    = "${module.db_option_group.db_option_group_id}"

  multi_az            = "${var.multi_az}"
  iops                = "${var.iops}"
  publicly_accessible = "${var.publicly_accessible}"

  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"
  apply_immediately           = "${var.apply_immediately}"
  maintenance_window          = "${var.maintenance_window}"
  skip_final_snapshot         = "${var.skip_final_snapshot}"
  copy_tags_to_snapshot       = "${var.copy_tags_to_snapshot}"
  final_snapshot_identifier   = "${local.common_name}-final-snapshot"

  backup_retention_period = "${var.mariadb_backup_retention_period}"
  backup_window           = "${var.backup_window}"

  monitoring_interval  = "${var.mariadb_monitoring_interval}"

  timezone           = "${var.timezone}"
  character_set_name = "${var.character_set_name}"

  tags = "${local.tags}"
}

###############################################
# Create route53 entry for mariadb
###############################################

resource "aws_route53_record" "mariadb_dns_entry" {
  name    = "${local.dns_name}.${local.internal_domain}"
  type    = "CNAME"
  zone_id = "${local.private_zone_id}"
  ttl     = 300
  records = ["${module.db_instance.db_instance_address}"]
}




############################################
# CREATE DB INSTANCE REPLICA
############################################

resource "aws_db_instance" "inst" {
  identifier                          = "${local.replica_common_name}"
  engine                              = "${var.engine}"
  engine_version                      = "${var.engine_version}"
  instance_class                      = "${var.rds_instance_class}"
  allocated_storage                   = "${var.rds_allocated_storage}"
  storage_type                        = "${var.storage_type}"
  storage_encrypted                   = "${var.storage_encrypted}"
  kms_key_id                          = "${module.kms_key.kms_arn}"
  username                            = ""
  password                            = ""
  port                                = "${var.port}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"
  replicate_source_db                 = "${module.db_instance.db_instance_id}"

  vpc_security_group_ids = [
    "${local.nextcloud_db_sg}",
  ]

  parameter_group_name = "${module.db_parameter_group.db_parameter_group_id}"
  option_group_name    = "${module.db_option_group.db_option_group_id}"
  multi_az             = "${var.multi_az}"
  iops                 = "${var.iops}"
  publicly_accessible  = "${var.publicly_accessible}"
  maintenance_window   = "Tue:00:00-Tue:01:00"
  tags                 = "${merge(local.tags, map("Name", format("%s", local.replica_common_name)))}"
}

###############################################
# Create route53 entry for maria db replica
###############################################

resource "aws_route53_record" "mariadb_dns_entry_replica" {
  name    = "${local.dns_name}-rpl.${local.internal_domain}"
  type    = "CNAME"
  zone_id = "${local.private_zone_id}"
  ttl     = 300
  records = ["${aws_db_instance.inst.address}"]
}
