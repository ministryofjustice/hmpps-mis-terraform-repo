####################################################
# SG Rules for lb
####################################################

### HTTPS in
resource "aws_security_group_rule" "https_in" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_mis_nextcloud_lb}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  description              = "TF - HTTPS in to LB"

  cidr_blocks = [
     "${local.user_access_cidr_blocks}",
    ]
}

resource "aws_security_group_rule" "http_in" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_mis_nextcloud_lb}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "egress"
  description              = "Lb out to nextcloud"
  source_security_group_id = "${data.terraform_remote_state.security-groups.sg_https_out}"
}

####################################################
# SG Rules for ASG
####################################################

resource "aws_security_group_rule" "asg_http_in" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_mis_app_in}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "HTTP in from LB"
  source_security_group_id = "${data.terraform_remote_state.security-groups.sg_mis_nextcloud_lb}"
}


####################################################
# SG Rules for EFS Share
####################################################

 resource "aws_security_group_rule" "nextcloud_efs_in" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_mis_nextcloud_efs_in}"
  from_port                = "2049"
  to_port                  = "2049"
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-efs-in"
  self                     = "true"
}

 resource "aws_security_group_rule" "nextcloud_efs_out" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_mis_nextcloud_efs_in}"
  from_port                = "2049"
  to_port                  = "2049"
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-efs-out"
  self                     = "true"
}

####################################################
# SG Rules for DB
####################################################

 resource "aws_security_group_rule" "nextcloud_db_in" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_mis_nextcloud_db}"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-db-in"
  self                     = "true"
}

 resource "aws_security_group_rule" "nextcloud_db_out" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_mis_nextcloud_db}"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-db-out"
  self                     = "true"
}


####################################################
# SG Rules for ldap
####################################################

resource "aws_security_group_rule" "ldap_in" {
  security_group_id        = "${data.terraform_remote_state.delius_core_security_groups.sg_apacheds_ldap_private_elb_id}"
  from_port                = 10389
  to_port                  = 10389
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "nextcloud in to ldap lb"
  source_security_group_id = "${data.terraform_remote_state.security-groups.sg_https_out}"
}

 resource "aws_security_group_rule" "ldap_out" {
  security_group_id        = "${data.terraform_remote_state.security-groups.sg_https_out}"
  from_port                = 10389
  to_port                  = 10389
  protocol                 = "tcp"
  type                     = "egress"
  description              = "nextcloud out to ldap lb"
  source_security_group_id = "${data.terraform_remote_state.delius_core_security_groups.sg_apacheds_ldap_private_elb_id}"
}
