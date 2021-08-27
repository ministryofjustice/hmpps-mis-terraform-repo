locals {
  alb_name    = "${local.short_environment_identifier}-bws"
  lb_endpoint = "ndl-bws"
  external_lb_security_groups = flatten([data.terraform_remote_state.security-groups.outputs.security_groups_sg_mis_app_lb])
}

#-------------------------------------------
# Load balancer
#-------------------------------------------
resource "aws_lb" "alb" {
  name               = "${local.alb_name}-alb"
  internal           = false
  security_groups    = local.external_lb_security_groups
  subnets            = local.public_subnet_ids
  load_balancer_type = "application"
  idle_timeout       = "1800"
  tags = merge(local.tags, { "Name" = "${local.alb_name}-alb" })

  access_logs {
    enabled = true
    bucket  = local.logs_bucket
    prefix  = "${local.alb_name}-alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#-------------------------------------------
# Target Group
#-------------------------------------------
resource "aws_lb_target_group" "bws" {
  name                 = "${local.alb_name}-tg"
  port                 = local.bws_port
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 60
  target_type          = "instance"

  health_check {
    interval            = "30"
    path                = "/BOE/BI"
    port                = local.bws_port
    protocol            = "HTTP"
    timeout             = "5"
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = "86400"
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.alb_name}-tg"
    },
  )
}

#-------------------------------------------
# Target Group Attachment
#-------------------------------------------
resource "aws_lb_target_group_attachment" "bws" {
  count            = var.bws_server_count
  target_group_arn = aws_lb_target_group.bws.arn
  target_id        = element(aws_instance.bws_server.*.id, count.index)
  port             = local.bws_port
  depends_on       = [aws_lb_target_group.bws]
}

#-------------------------------------------
# Listeners
#-------------------------------------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.bws.arn
    type             = "forward"
  }
}

#-------------------------------------------
# DNS
#-------------------------------------------
resource "aws_route53_record" "bws_lb" {
  zone_id = local.public_zone_id
  name    = "${local.lb_endpoint}.${local.external_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}
