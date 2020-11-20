
resource "aws_security_group" "mis-fsx-integration" {
  name        = local.security_group_name
  description = "security group to allow MIS instances access to fsx filesystem"
  vpc_id      = local.vpc_id

  # internal traffic
  ingress {
    description = "ingress internal security group traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
  }

  egress {
    description = "egress internal security group traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
  }

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
