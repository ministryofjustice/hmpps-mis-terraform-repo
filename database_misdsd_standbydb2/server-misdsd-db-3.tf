module "misdsd_db_3" {
  source      = "git::https://github.com/ministryofjustice/hmpps-oracle-database.git//modules/oracle-database?ref=2.1.0"
  server_name = "misdsd-db-3"

  ami_id               = data.aws_ami.centos_oracle_db.id
  db_subnet            = data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az3
  key_name             = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  iam_instance_profile = data.terraform_remote_state.iam.outputs.iam_policy_int_mis_db_instance_profile_name

  security_group_ids = [
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
    data.terraform_remote_state.security-groups.outputs.sg_map_ids["sg_mis_app_in"],
    data.terraform_remote_state.security-groups.outputs.sg_map_ids["sg_mis_common"],
    data.terraform_remote_state.common.outputs.common_sg_outbound_id,
    data.terraform_remote_state.vpc_security_groups.outputs.sg_mis_db_in_out_rman_cat_id,
  ]

  tags                         = local.tags
  environment_name             = data.terraform_remote_state.vpc.outputs.environment_name
  bastion_inventory            = data.terraform_remote_state.vpc.outputs.bastion_inventory
  project_name                 = var.project_name
  environment_identifier       = var.environment_identifier
  short_environment_identifier = var.short_environment_identifier

  environment_type = var.environment_type
  region           = var.region

  kms_key_id      = data.terraform_remote_state.misdsd-db-1.outputs.kms_arn
  public_zone_id  = data.terraform_remote_state.vpc.outputs.public_zone_id
  private_zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  private_domain  = data.terraform_remote_state.vpc.outputs.private_zone_name
  vpc_account_id  = data.terraform_remote_state.vpc.outputs.vpc_account_id
  db_size         = var.db_size_misdsd

  ansible_vars = {
    service_user_name             = var.ansible_vars_misdsd_db["service_user_name"]
    database_global_database_name = "${var.ansible_vars_misdsd_db["database_global_database_name"]}S2"
    database_sid                  = "${var.ansible_vars_misdsd_db["database_sid"]}S2"
    database_characterset         = var.ansible_vars_misdsd_db["database_characterset"]
    oracle_dbca_template_file     = var.ansible_vars_misdsd_db["oracle_dbca_template_file"]
    database_type                 = "standby" # required for the DB module. This file is where the property is set.
    dependencies_bucket_arn       = var.dependencies_bucket_arn
    s3_oracledb_backups_arn       = data.terraform_remote_state.s3-oracledb-backups.outputs.s3_oracledb_backups.arn
    s3_oracledb_backups_inventory_arn       = data.terraform_remote_state.s3-oracledb-backups.outputs.s3_oracledb_backups_inventory.arn
  }
  ## the following are retrieved from SSM Parameter Store
  ## oradb_sys_password            = "/${environment_name}/mis/misdsd-database/db/oradb_sys_password"
  ## oradb_system_password         = "/${environment_name}/mis/misdsd-database/db/oradb_system_password"
  ## oradb_dbsnmp_password         = "/${environment_name}/mis/misdsd-database/db/oradb_dbsnmp_password"
  ## oradb_asmsnmp_password        = "/${environment_name}/mis/misdsd-database/db/oradb_asmsnmp_password"
}

#legacy (used for info only)
output "ami_misdsd_db_3" {
  value = module.misdsd_db_3.ami_id
}

output "public_fqdn_misdsd_db_3" {
  value = module.misdsd_db_3.public_fqdn
}

output "internal_fqdn_misdsd_db_3" {
  value = module.misdsd_db_3.internal_fqdn
}

output "private_ip_misdsd_db_3" {
  value = module.misdsd_db_3.private_ip
}

output "db_disks_misdsd_db_3" {
  value = module.misdsd_db_3.db_size_parameters
}

# map (tidier)
output "misdsd_db_3" {
  value = {
    ami_id        = module.misdsd_db_3.ami_id
    public_fqdn   = module.misdsd_db_3.public_fqdn
    internal_fqdn = module.misdsd_db_3.internal_fqdn
    private_ip    = module.misdsd_db_3.private_ip
    db_disks      = module.misdsd_db_3.db_size_parameters
    misdsd_db_3   = "ssh ${module.misdsd_db_3.public_fqdn}"
  }
}
