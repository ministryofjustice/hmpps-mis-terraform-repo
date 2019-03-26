# app lb
resource "aws_security_group_rule" "lb_https_in" {
  security_group_id = "${local.sg_mis_app_lb}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-https-in"

  cidr_blocks = [
    "${local.user_access_cidr_blocks}",
  ]
}
