locals {
  lb_name     = "${local.short_environment_identifier}-${local.nart_role}"
  lb_endpoint = "ndl-dfi"
  external_lb_security_groups = flatten([data.terraform_remote_state.security-groups.outputs.security_groups_sg_mis_app_lb])
}

############################################
# CREATE LB FOR dfi
############################################

# elb
resource "aws_elb" "dfi" {
  count           = var.dfi_server_resources
  name            = local.lb_name
  subnets         = local.public_subnet_ids
  internal        = false
  security_groups = local.external_lb_security_groups

  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout

  listener {
    instance_port     = local.dfi_port
    instance_protocol = var.http_protocol
    lb_port           = var.http_port
    lb_protocol       = var.http_protocol
  }

  listener {
    instance_port      = local.dfi_port
    instance_protocol  = var.http_protocol
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = local.certificate_arn
  }

  access_logs {
    bucket        = local.logs_bucket
    bucket_prefix = local.lb_name
    interval      = 60
  }

  health_check {
      target              = "HTTP:8080/DataServices/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    }

  tags = merge(
    local.tags,
    {
      "Name" = format("%s", local.lb_name)
    },
  )
}



###############################################
# Create route53 entry for case notes lb
###############################################

resource "aws_route53_record" "dns_entry" {
  count   = var.dfi_server_resources
  zone_id = local.public_zone_id
  name    = "${local.lb_endpoint}.${local.external_domain}"
  type    = "A"

  alias {
    name                   = element(concat(aws_elb.dfi.*.dns_name, [""]), 0)
    zone_id                = element(concat(aws_elb.dfi.*.zone_id, [""]), 0)
    evaluate_target_health = false
  }
}

resource "aws_lb_cookie_stickiness_policy" "dfi" {
  count         = var.dfi_server_resources
  name          = "dfi-policy"
  load_balancer = element(concat(aws_elb.dfi.*.name, [""]), 0)
  lb_port       = 443
}

#-------------------------------------------------------------
# Create elb attachments
#-------------------------------------------------------------
resource "aws_elb_attachment" "dfi" {
  count    = var.dfi_server_resources
  elb      = element(concat(aws_elb.dfi.*.name, [""]), 0)
  instance = element(aws_instance.dfi_server.*.id, count.index)
}
