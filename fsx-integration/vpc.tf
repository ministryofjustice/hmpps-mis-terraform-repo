
resource "aws_security_group" "mis_fsx_integration" {
  name        = local.security_group_name
  description = "security group to allow MIS instances access to fsx filesystem"
  vpc_id      = local.vpc_id

  tags = merge(
    local.tags,
    {
      "Name" = local.security_group_name
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "mis_fsx_integration_ingress_all_local_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  security_group_id        = aws_security_group.mis_fsx_integration.id
  self                     = true
  description              = "ingress internal security group traffic"
}

resource "aws_security_group_rule" "mis_fsx_integration_egress_all_local_sg" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  security_group_id        = aws_security_group.mis_fsx_integration.id
  self                     = true
  description              = "egress internal security group traffic"
}