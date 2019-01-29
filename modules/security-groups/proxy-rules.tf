# ldap lb
resource "aws_security_group_rule" "lb_ldap_https" {
  security_group_id = "${local.sg_ldap_lb}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-ldap-https-in"

  cidr_blocks = [
    "${local.allowed_cidr_block}",
  ]
}

resource "aws_security_group_rule" "lb_ldap_http" {
  security_group_id = "${local.sg_ldap_lb}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-ldap-http-in"

  cidr_blocks = [
    "${local.allowed_cidr_block}",
  ]
}

# egress
resource "aws_security_group_rule" "ldap_lb_http_out" {
  security_group_id        = "${local.sg_ldap_lb}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-http-out"
  source_security_group_id = "${local.sg_ldap_proxy}"
}

resource "aws_security_group_rule" "ldap_lb_https_out" {
  security_group_id        = "${local.sg_ldap_lb}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-https-out"
  source_security_group_id = "${local.sg_ldap_proxy}"
}

#### proxy instance

# ingress
resource "aws_security_group_rule" "ldap_lb_http_in" {
  security_group_id        = "${local.sg_ldap_proxy}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-http-in"
  source_security_group_id = "${local.sg_ldap_lb}"
}

resource "aws_security_group_rule" "ldap_lb_https_in" {
  security_group_id        = "${local.sg_ldap_proxy}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-https-in"
  source_security_group_id = "${local.sg_ldap_lb}"
}
