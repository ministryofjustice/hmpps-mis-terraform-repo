####################################################
# SECURITY GROUPS - Application specific
####################################################
output "security_groups_sg_mis_app_in" {
  value = "${module.security_groups.security_groups_sg_mis_app_in}"
}

output "security_groups_sg_mis_common" {
  value = "${module.security_groups.security_groups_sg_mis_common}"
}

output "security_groups_sg_mis_db_in" {
  value = "${module.security_groups.security_groups_sg_mis_db_in}"
}

output "security_groups_sg_mis_app_lb" {
  value = "${module.security_groups.security_groups_sg_mis_app_lb}"
}

output "security_groups_sg_ldap_lb" {
  value = "${module.security_groups.security_groups_sg_ldap_lb}"
}

output "security_groups_sg_ldap_inst" {
  value = "${module.security_groups.security_groups_sg_ldap_inst}"
}
