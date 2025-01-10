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
}

resource "aws_route53_record" "mis_db1_migration_internal" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "mis-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-mis-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "mis_db1_migration_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "mis-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-mis-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "boe_db1_migration_internal" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "misboe-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-boe-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "boe_db1_migration_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "misboe-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-boe-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "dsd_db1_migration_internal" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "misdsd-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-dsd-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "dsd_db1_migration_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "misdsd-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-mis-${local.legacy_to_mp_env[var.environment_name]}-dsd-db-1.delius-mis.hmpps-${local.legacy_to_mp_vpc[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}
