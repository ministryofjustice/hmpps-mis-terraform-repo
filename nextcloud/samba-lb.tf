# Samba lb access

locals {
  samba_lb_name = "${local.short_environment_identifier}-samba"
}

resource "aws_elb" "samba_lb" {
  name                 = "${local.samba_lb_name}-elb"
  internal             = true
  subnets              = flatten(local.private_subnet_ids)
  tags                 = local.tags
  security_groups      = flatten([local.nextcloud_samba_sg])
  listener {
    instance_port     = "445"
    instance_protocol = "tcp"
    lb_port           = "445"
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:445"
    interval            = 30
  }
}

resource "aws_route53_record" "samba_lb_private" {
  zone_id = local.private_zone_id
  name    = "samba.${local.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elb.samba_lb.dns_name]
}
