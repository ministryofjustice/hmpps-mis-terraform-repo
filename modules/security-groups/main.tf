####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################
locals {
  common_name        = "${var.common_name}"
  vpc_id             = "${var.vpc_id}"
  allowed_cidr_block = ["${var.allowed_cidr_block}"]
  bastion_cidr       = ["${var.bastion_cidr}"]
  tags               = "${var.tags}"

  public_cidr_block = ["${var.public_cidr_block}"]

  private_cidr_block = ["${var.private_cidr_block}"]

  db_cidr_block = ["${var.db_cidr_block}"]
  sg_mis_app_in = "${var.sg_map_ids["sg_mis_app_in"]}"
  sg_mis_common = "${var.sg_map_ids["sg_mis_common"]}"
  sg_mis_db_in  = "${var.sg_map_ids["sg_mis_db_in"]}"
  sg_mis_app_lb = "${var.sg_map_ids["sg_mis_app_lb"]}"
  sg_ldap_lb    = "${var.sg_map_ids["sg_ldap_lb"]}"
  sg_ldap_inst  = "${var.sg_map_ids["sg_ldap_inst"]}"
}

#######################################
# SECURITY GROUPS
#######################################

# app lb
resource "aws_security_group_rule" "lb_https_in" {
  security_group_id = "${local.sg_mis_app_lb}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-https-in"

  cidr_blocks = [
    "${local.allowed_cidr_block}",
  ]
}
