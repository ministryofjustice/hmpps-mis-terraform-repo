# All local open
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

#-------------------------------------------------------------
### common sg rules
#-------------------------------------------------------------
resource "aws_security_group_rule" "rdp_in" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-rdp-in"
  source_security_group_id = "${local.sg_jumphost}"
}

resource "aws_security_group_rule" "ssh_in" {
  security_group_id = "${local.sg_mis_common}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-ssh-in"

  cidr_blocks = [
    "${local.bastion_cidr}",
  ]
}

#-------------------------------------------------------------
### jumphost sg rules
#-------------------------------------------------------------
resource "aws_security_group_rule" "rdp_in_jumphost" {
  security_group_id = "${local.sg_jumphost}"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-rdp-in-jumphost"

  cidr_blocks = [
    "${local.bastion_cidr}",
  ]
}
