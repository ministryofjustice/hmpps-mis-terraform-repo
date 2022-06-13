#Overide autostop tag
locals {
  overide_tags = merge(
    local.tags,
    {
      "autostop-${var.environment_type}" = var.delius_overide_autostop_tags
    },
  )
}

module "mis_db_1" {
  source      = "git::https://github.com/ministryofjustice/hmpps-oracle-database.git//modules/oracle-database?ref=2.6.0"
  server_name = "mis-db-1"

  ami_id               = data.aws_ami.centos_oracle_db.id
  db_subnet            = data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az1
  key_name             = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  iam_instance_profile = data.terraform_remote_state.iam.outputs.iam_policy_int_mis_db_instance_profile_name

  security_group_ids = [
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
    data.terraform_remote_state.security-groups.outputs.sg_map_ids["sg_mis_app_in"],
    data.terraform_remote_state.security-groups.outputs.sg_map_ids["sg_mis_common"],
    data.terraform_remote_state.common.outputs.common_sg_outbound_id,
    data.terraform_remote_state.vpc_security_groups.outputs.sg_mis_out_to_delius_db_id,
  ]

  tags                         = local.overide_tags
  environment_name             = data.terraform_remote_state.vpc.outputs.environment_name
  bastion_inventory            = data.terraform_remote_state.vpc.outputs.bastion_inventory
  project_name                 = var.project_name
  environment_identifier       = var.environment_identifier
  short_environment_identifier = var.short_environment_identifier

  environment_type = var.environment_type
  region           = var.region

  kms_key_id      = module.kms_key_mis_db.kms_arn
  public_zone_id  = data.terraform_remote_state.vpc.outputs.public_zone_id
  private_zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  private_domain  = data.terraform_remote_state.vpc.outputs.private_zone_name
  vpc_account_id  = data.terraform_remote_state.vpc.outputs.vpc_account_id
  db_size         = var.db_size_mis

  ansible_vars = {
    service_user_name             = var.ansible_vars_mis_db["service_user_name"]
    database_global_database_name = var.ansible_vars_mis_db["database_global_database_name"]
    database_sid                  = var.ansible_vars_mis_db["database_sid"]
    database_characterset         = var.ansible_vars_mis_db["database_characterset"]
    oracle_dbca_template_file     = var.ansible_vars_mis_db["oracle_dbca_template_file"]
    database_type                 = "primary" # required for the DB module. This file is where the property is set.
    dependencies_bucket_arn       = var.dependencies_bucket_arn
    s3_oracledb_backups_arn       = data.terraform_remote_state.s3-oracledb-backups.outputs.s3_oracledb_backups.arn
    s3_oracledb_backups_inventory_arn       = data.terraform_remote_state.s3-oracledb-backups.outputs.s3_oracledb_backups_inventory.arn
    database_bootstrap_restore    = var.ansible_vars_mis_db["database_bootstrap_restore"]
    database_backup               = var.ansible_vars_mis_db["database_backup"]
    database_backup_sys_passwd    = var.ansible_vars_mis_db["database_backup_sys_passwd"]
    database_backup_location      = var.ansible_vars_mis_db["database_backup_location"]
  }
  ## the following are retrieved from SSM Parameter Store
  ## oradb_sys_password            = "/${environment_name}/mis/mis-database/db/oradb_sys_password"
  ## oradb_system_password         = "/${environment_name}/mis/mis-database/db/oradb_system_password"
  ## oradb_dbsnmp_password         = "/${environment_name}/mis/mis-database/db/oradb_dbsnmp_password"
  ## oradb_asmsnmp_password        = "/${environment_name}/mis/mis-database/db/oradb_asmsnmp_password"
}

#legacy (used for info only)
output "ami_mis_db_1" {
  value = module.mis_db_1.ami_id
}

output "public_fqdn_mis_db_1" {
  value = module.mis_db_1.public_fqdn
}

output "internal_fqdn_mis_db_1" {
  value = module.mis_db_1.internal_fqdn
}

output "private_ip_mis_db_1" {
  value = module.mis_db_1.private_ip
}

output "db_disks_mis_db_1" {
  value = module.mis_db_1.db_size_parameters
}

# map (tidier)
output "mis_db_1" {
  value = {
    ami_id        = module.mis_db_1.ami_id
    public_fqdn   = module.mis_db_1.public_fqdn
    internal_fqdn = module.mis_db_1.internal_fqdn
    private_ip    = module.mis_db_1.private_ip
    db_disks      = module.mis_db_1.db_size_parameters
    mis_db_1      = "ssh ${module.mis_db_1.public_fqdn}"
  }
}
