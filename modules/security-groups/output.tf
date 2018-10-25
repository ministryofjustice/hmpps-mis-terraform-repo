# SECURITY GROUPS

output "security_groups_sg_mis_app_in" {
  value = "${local.sg_mis_app_in}"
}

output "security_groups_sg_mis_common" {
  value = "${local.sg_mis_common}"
}

output "security_groups_sg_mis_db_in" {
  value = "${local.sg_mis_db_in}"
}

output "security_groups_sg_mis_jumphost" {
  value = "${local.sg_mis_jumphost}"
}
