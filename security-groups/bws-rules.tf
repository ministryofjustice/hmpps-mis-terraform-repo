resource "aws_security_group_rule" "bws_ldap_in" {
  security_group_id        = "${data.terraform_remote_state.delius_core_security_groups.sg_apacheds_ldap_private_elb_id}"
  from_port                = 10389
  to_port                  = 10389
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "bws in to ldap lb"
  source_security_group_id = "${data.terraform_remote_state.security-groups.sg_bws_ldap}"
}

 resource "aws_security_group_rule" "bws_ldap_out" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_bws_ldap}"
  from_port                = 10389
  to_port                  = 10389
  protocol                 = "tcp"
  type                     = "egress"
  description              = "bws out to ldap lb"
  source_security_group_id = "${data.terraform_remote_state.delius_core_security_groups.sg_apacheds_ldap_private_elb_id}"
}
