resource "aws_security_group" "hmpp_route53_resolver" {
  count = var.modernisation_platform_hmpp_domain_name != null ? 1 : 0

  name        = "hmpp-route53-resolver-sg"
  description = "Route53 resolver security group for ForwardToHMPPDomainTF"
  vpc_id      = local.vpc_id

  tags = merge(local.tags, {
    Name = "hmpp-route53-resolver-sg"
  })
}

resource "aws_security_group_rule" "hmpp_route53_resolver_53_tcp" {
  count = var.modernisation_platform_hmpp_domain_name != null ? 1 : 0

  type              = "egress"
  description       = "Allow outbound tcp/53"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.hmpp_route53_resolver[0].id
}

resource "aws_security_group_rule" "hmpp_route53_resolver_53_udp" {
  count = var.modernisation_platform_hmpp_domain_name != null ? 1 : 0

  type              = "egress"
  description       = "Allow outbound udp/53"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.hmpp_route53_resolver[0].id
}

resource "aws_route53_resolver_endpoint" "hmpp_route53_resolver" {
  count = var.modernisation_platform_hmpp_domain_name != null ? 1 : 0

  name               = "ForwardToHMPPDomainTF"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.hmpp_route53_resolver[0].id]

  dynamic "ip_address" {
    for_each = var.private_subnet_map

    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(local.tags, {
    Name = "ForwardToHMPPDomainTF"
  })
}

resource "aws_route53_resolver_rule" "hmpp_route53_resolver_hmpp" {
  count = var.modernisation_platform_hmpp_domain_name != null ? 1 : 0

  domain_name = var.modernisation_platform_hmpp_domain_name
  name        = "forward-to-hmpp-domain"
  rule_type   = "FORWARD"

  resolver_endpoint_id = aws_route53_resolver_endpoint.hmpp_route53_resolver[0].id

  dynamic "target_ip" {
    for_each = var.modernisation_platform_hmpp_dc_ips
    content {
      ip = target_ip.value
    }
  }

  tags = merge(local.tags, {
    Name = "forward-to-hmpp-domain"
  })
}

resource "aws_route53_resolver_rule_association" "this" {
  count = var.modernisation_platform_hmpp_domain_name != null ? 1 : 0

  resolver_rule_id = aws_route53_resolver_rule.hmpp_route53_resolver_hmpp[0].id
  vpc_id           = local.vpc_id
}
