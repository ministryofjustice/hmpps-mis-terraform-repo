locals {
  legacy_to_mp_env = {
    "delius-mis-dev"  = "dev"
    "delius-test"     = "test"
    "delius-stage"    = "stage"
    "delius-pre-prod" = "preprod"
  }
  legacy_to_mp_vpc = {
    "delius-mis-dev"  = "development"
    "delius-test"     = "test"
    "delius-stage"    = "preproduction"
    "delius-pre-prod" = "preproduction"
  }
  migrated_envs = {
    "delius-mis-dev"  = ["mis-db-1", "misboe-db-1", "misdsd-db-1"]
    "delius-test"     = []
    "delius-stage"    = ["mis-db-1", "misboe-db-1", "misdsd-db-1"]
    "delius-pre-prod" = ["mis-db-1", "mis-db-2"]
  }
}

resource "aws_route53_record" "mis_db1_migration_internal" {
  count   = contains(local.migrated_envs[var.environment_name], "mis-db-1") ? 1 : 0
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "mis-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-mis-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "mis_db1_migration_public" {
  count   = contains(local.migrated_envs[var.environment_name], "mis-db-1") ? 1 : 0
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "mis-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-mis-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]

}
resource "aws_route53_record" "mis_db2_migration_public" {
  count   = contains(local.migrated_envs[var.environment_name], "mis-db-2") ? 1 : 0
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "mis-db-2"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-mis-db-2.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "mis_db2_migration_internal" {
  count   = contains(local.migrated_envs[var.environment_name], "mis-db-2") ? 1 : 0
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "mis-db-2"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-mis-db-2.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "boe_db1_migration_internal" {
  count   = contains(local.migrated_envs[var.environment_name], "misboe-db-1") ? 1 : 0
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "misboe-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-boe-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "boe_db1_migration_public" {
  count   = contains(local.migrated_envs[var.environment_name], "misboe-db-1") ? 1 : 0
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "misboe-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-boe-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "dsd_db1_migration_internal" {
  count   = contains(local.migrated_envs[var.environment_name], "misdsd-db-1") ? 1 : 0
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "misdsd-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-dsd-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "dsd_db1_migration_public" {
  count   = contains(local.migrated_envs[var.environment_name], "misdsd-db-1") ? 1 : 0
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "misdsd-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-dsd-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}
