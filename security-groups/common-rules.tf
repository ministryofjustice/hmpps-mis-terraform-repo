# All local open
resource "aws_security_group_rule" "local_ingress" {
  security_group_id = local.sg_mis_common
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}

resource "aws_security_group_rule" "local_egress" {
  security_group_id = local.sg_mis_common
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
  security_group_id = local.sg_mis_common
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-rdp-in"
  cidr_blocks = concat(
    local.bastion_cidr,
  )
}

resource "aws_security_group_rule" "ssh_in" {
  security_group_id = local.sg_mis_common
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-ssh-in"
  cidr_blocks = concat(
    local.bastion_cidr,
  )
}

resource "aws_security_group_rule" "common_out_oracle_tcp" {
  security_group_id = aws_security_group.common_out.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1522
  cidr_blocks       = ["10.27.0.0/21", "10.27.8.0/21", "10.26.8.0/21", "10.26.24.0/21"]
  description       = "Oracle out to MP tcp"
}
