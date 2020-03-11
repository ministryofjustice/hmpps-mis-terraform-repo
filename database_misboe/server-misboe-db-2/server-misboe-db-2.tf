module "misboe_db_2" {
  source      = "git::https://github.com/ministryofjustice/hmpps-oracle-database.git?ref=master//modules//oracle-database"
  server_name = "misboe-db-2"

  ami_id               = "${data.aws_ami.centos_oracle_db.id}"
  db_subnet            = "${data.terraform_remote_state.vpc.vpc_db-subnet-az2}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.iam.iam_policy_int_mis_db_instance_profile_name}"

  security_group_ids = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.security-groups.sg_map_ids["sg_mis_app_in"]}",
    "${data.terraform_remote_state.security-groups.sg_map_ids["sg_mis_common"]}",
    "${data.terraform_remote_state.common.common_sg_outbound_id}",
    "${data.terraform_remote_state.vpc_security_groups.sg_mis_db_in_out_rman_cat_id}"
  ]

  tags                         = "${var.tags}"
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  bastion_inventory            = "${data.terraform_remote_state.vpc.bastion_inventory}"
  project_name                 = "${var.project_name}"
  environment_identifier       = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"

  environment_type = "${var.environment_type}"
  region           = "${var.region}"

  #kms_key_id      = "${module.kms_key_misboe_db.kms_arn}"
  kms_key_id      = "${data.terraform_remote_state.misboe-db-1.kms_arn}"
  public_zone_id  = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
  private_domain  = "${data.terraform_remote_state.vpc.private_zone_name}"
  vpc_account_id  = "${data.terraform_remote_state.vpc.vpc_account_id}"
  db_size         = "${var.db_size_misboe}"

  ansible_vars = {
    service_user_name             = "${var.ansible_vars_misboe_db["service_user_name"]}"
    database_global_database_name = "${var.ansible_vars_misboe_db["database_global_database_name"]}"
    database_sid                  = "${var.ansible_vars_misboe_db["database_sid"]}"
    database_characterset         = "${var.ansible_vars_misboe_db["database_characterset"]}"
    oracle_dbca_template_file     = "${var.ansible_vars_misboe_db["oracle_dbca_template_file"]}"
    database_type                 = "standby" # required for the DB module. This file is where the property is set.
    dependencies_bucket_arn       = "${var.dependencies_bucket_arn}"
    s3_oracledb_backups_arn       = "${data.terraform_remote_state.s3-oracledb-backups.s3_oracledb_backups.arn}"

    ## the following are retrieved from SSM Parameter Store
    ## oradb_sys_password            = "/${environment_name}/mis/misboe-database/db/oradb_sys_password"
    ## oradb_system_password         = "/${environment_name}/mis/misboe-database/db/oradb_system_password"
    ## oradb_sysman_password         = "/${environment_name}/mis/misboe-database/db/oradb_sysman_password"
    ## oradb_dbsnmp_password         = "/${environment_name}/mis/misboe-database/db/oradb_dbsnmp_password"
    ## oradb_asmsnmp_password        = "/${environment_name}/mis/misboe-database/db/oradb_asmsnmp_password"
  }
}

#legacy (used for info only)
output "ami_misboe_db_2" {
  value = "${module.misboe_db_2.ami_id}"
}

output "public_fqdn_misboe_db_2" {
  value = "${module.misboe_db_2.public_fqdn}"
}

output "internal_fqdn_misboe_db_2" {
  value = "${module.misboe_db_2.internal_fqdn}"
}

output "private_ip_misboe_db_2" {
  value = "${module.misboe_db_2.private_ip}"
}

output "db_disks_misboe_db_2" {
  value = "${module.misboe_db_2.db_size_parameters}"
}

# map (tidier)
output "misboe_db_2" {
  value = {
    ami_id        = "${module.misboe_db_2.ami_id}",
    public_fqdn   = "${module.misboe_db_2.public_fqdn}",
    internal_fqdn = "${module.misboe_db_2.internal_fqdn}",
    private_ip    = "${module.misboe_db_2.private_ip}",
    db_disks      = "${module.misboe_db_2.db_size_parameters}",
    misboe_db_2   = "ssh ${module.misboe_db_2.public_fqdn}",
  }
}
