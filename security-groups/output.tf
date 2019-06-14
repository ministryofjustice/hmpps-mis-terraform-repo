# ####################################################
# SECURITY GROUPS - Application specific
####################################################

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
  value = "${local.sg_mis_app_lb}"
}

output "security_groups_sg_ldap_inst" {
  value = "${local.sg_ldap_inst}"
}

output "security_groups_sg_ldap_proxy" {
  value = "${local.sg_ldap_proxy}"
}

# Security groups
output "sg_map_ids" {
  value = "${local.sg_map_ids}"
}

output "bws_port" {
  value = "${local.bws_port}"
}
