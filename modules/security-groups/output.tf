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

output "security_groups_sg_mis_app_lb" {
  value = "${local.sg_mis_app_lb}"
}

output "security_groups_sg_ldap_lb" {
  value = "${local.sg_ldap_lb}"
}

output "security_groups_sg_ldap_inst" {
  value = "${local.sg_ldap_inst}"
}
