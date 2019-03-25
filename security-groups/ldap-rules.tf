# instance
resource "aws_security_group_rule" "ldap_http_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-http-in"
  source_security_group_id = "${local.sg_mis_common}"
}

resource "aws_security_group_rule" "ldap_https_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-https-in"
  source_security_group_id = "${local.sg_mis_common}"
}

resource "aws_security_group_rule" "ldap_ldap_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 389
  to_port                  = 389
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-ldap-in"
  source_security_group_id = "${local.sg_mis_common}"
}

resource "aws_security_group_rule" "ldap_ldaps_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 636
  to_port                  = 636
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-ldaps-in"
  source_security_group_id = "${local.sg_mis_common}"
}

resource "aws_security_group_rule" "ldap_kerberos_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 88
  to_port                  = 88
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-kerberos-in"
  source_security_group_id = "${local.sg_mis_common}"
}

resource "aws_security_group_rule" "ldap_kerberos_udp_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 88
  to_port                  = 88
  protocol                 = "udp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-kerberos-in"
  source_security_group_id = "${local.sg_mis_common}"
}

resource "aws_security_group_rule" "ldap_kerberos_2_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 464
  to_port                  = 464
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-kerberos-in"
  source_security_group_id = "${local.sg_mis_common}"
}

resource "aws_security_group_rule" "ldap_kerberos_2_udp_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 464
  to_port                  = 464
  protocol                 = "udp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-kerberos-in"
  source_security_group_id = "${local.sg_mis_common}"
}

resource "aws_security_group_rule" "ldap_ntp_in" {
  security_group_id        = "${local.sg_ldap_inst}"
  from_port                = 123
  to_port                  = 123
  protocol                 = "udp"
  type                     = "ingress"
  description              = "${local.common_name}-ldap-ntp-in"
  source_security_group_id = "${local.sg_mis_common}"
}

# egress

resource "aws_security_group_rule" "ldap_http_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-http-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

resource "aws_security_group_rule" "ldap_https_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-https-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

resource "aws_security_group_rule" "ldap_ldap_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 389
  to_port                  = 389
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-ldap-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

resource "aws_security_group_rule" "ldap_ldaps_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 636
  to_port                  = 636
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-ldaps-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

resource "aws_security_group_rule" "ldap_kerberos_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 88
  to_port                  = 88
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-kerberos-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

resource "aws_security_group_rule" "ldap_kerberos_udp_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 88
  to_port                  = 88
  protocol                 = "udp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-kerberos-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

resource "aws_security_group_rule" "ldap_kerberos_2_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 464
  to_port                  = 464
  protocol                 = "tcp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-kerberos-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

resource "aws_security_group_rule" "ldap_kerberos_2_udp_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 464
  to_port                  = 464
  protocol                 = "udp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-kerberos-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

resource "aws_security_group_rule" "ldap_ntp_out" {
  security_group_id        = "${local.sg_mis_common}"
  from_port                = 123
  to_port                  = 123
  protocol                 = "udp"
  type                     = "egress"
  description              = "${local.common_name}-ldap-ntp-out"
  source_security_group_id = "${local.sg_ldap_inst}"
}

# ldap lb
resource "aws_security_group_rule" "lb_ldap_https" {
  security_group_id = "${local.sg_ldap_lb}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-lb-ldap-https-in"

  cidr_blocks = [
    "${local.user_access_cidr_blocks}",
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
    "${local.user_access_cidr_blocks}",
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
