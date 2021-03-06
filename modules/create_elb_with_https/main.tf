resource "aws_elb" "environment" {
  name            = var.name
  subnets         = var.subnets
  internal        = var.internal
  security_groups = var.security_groups

  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout

  listener {
    instance_port     = var.instance_port
    instance_protocol = var.instance_protocol
    lb_port           = var.lb_port
    lb_protocol       = var.lb_protocol
  }

  listener {
    instance_port      = var.instance_port
    instance_protocol  = var.instance_protocol
    lb_port            = var.lb_port_https
    lb_protocol        = var.lb_protocol_https
    ssl_certificate_id = var.ssl_certificate_id
  }

  access_logs {
    bucket        = var.bucket
    bucket_prefix = var.bucket_prefix
    interval      = var.interval
  }

  health_check {
      target              = var.target
      interval            = var.lb_interval
      healthy_threshold   = var.healthy_threshold
      unhealthy_threshold = var.unhealthy_threshold
      timeout             = var.timeout
    }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}
