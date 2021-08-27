# app lb
resource "aws_security_group_rule" "lb_https_in" {
  security_group_id = local.sg_mis_app_lb
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-https-in"

  cidr_blocks = concat(
    local.user_access_cidr_blocks,
    local.env_user_access_cidr_blocks,
    local.bastion_public_ip,
  )
}

resource "aws_security_group_rule" "lb_http_in" {
  security_group_id = local.sg_mis_app_lb
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-http-in"

  cidr_blocks = concat(
    local.user_access_cidr_blocks,
    local.env_user_access_cidr_blocks,
    local.bastion_public_ip,
  )
}

resource "aws_security_group_rule" "bws_lb_http_egress" {
  security_group_id        = local.sg_mis_app_lb
  from_port                = local.bws_port
  to_port                  = local.bws_port
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-bws-http-out"
  source_security_group_id = local.sg_mis_app_in
}

resource "aws_security_group_rule" "bws_lb_http_in" {
  security_group_id        = local.sg_mis_app_in
  from_port                = local.bws_port
  to_port                  = local.bws_port
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-bws-http-in"
  source_security_group_id = local.sg_mis_app_lb
}

resource "aws_security_group_rule" "bws_lb_https_ingress_from_codebuild" {
  security_group_id        = local.sg_mis_app_lb
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-lb-https-in-codebuild"
  cidr_blocks = concat(
      local.natgateway_az1,
      local.natgateway_az2,
      local.natgateway_az3,
  )
}
