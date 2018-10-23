####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################
locals {
  common_name        = "${var.environment_identifier}-${var.app_name}"
  vpc_id             = "${var.vpc_id}"
  allowed_cidr_block = "${var.allowed_cidr_block}"
  tags               = "${var.tags}"

  public_cidr_block = ["${var.public_cidr_block}"]

  private_cidr_block = ["${var.private_cidr_block}"]

  db_cidr_block = ["${var.db_cidr_block}"]
  sg_mis_app_in = "${var.sg_map_ids["sg_mis_app_in"]}"
  sg_mis_common = "${var.sg_map_ids["sg_mis_common"]}"
  sg_mis_db_in  = "${var.sg_map_ids["sg_mis_db_in"]}"
}

#######################################
# SECURITY GROUPS
#######################################
#-------------------------------------------------------------
### app
#-------------------------------------------------------------

resource "aws_security_group_rule" "rdp_in" {
  security_group_id = "${local.sg_mis_app_in}"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-rdp-in"

  cidr_blocks = [
    "${local.allowed_cidr_block}",
  ]
}

#-------------------------------------------------------------
### common sg rules
#-------------------------------------------------------------
resource "aws_security_group_rule" "local_ingress" {
  security_group_id = "${local.sg_mis_common}"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}

resource "aws_security_group_rule" "local_egress" {
  security_group_id = "${local.sg_mis_common}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}
