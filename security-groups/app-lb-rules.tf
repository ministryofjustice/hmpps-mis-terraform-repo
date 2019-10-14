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
    "${local.env_user_access_cidr_blocks}",
  ]
}

resource "aws_security_group_rule" "bws_lb_http_egress" {
  security_group_id        = "${local.sg_mis_app_lb}"
  from_port                = "${local.bws_port}"
  to_port                  = "${local.bws_port}"
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-bws-http-out"
  source_security_group_id = "${local.sg_mis_app_in}"
}

resource "aws_security_group_rule" "bws_lb_http_in" {
  security_group_id        = "${local.sg_mis_app_in}"
  from_port                = "${local.bws_port}"
  to_port                  = "${local.bws_port}"
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-bws-http-in"
  source_security_group_id = "${local.sg_mis_app_lb}"
}
