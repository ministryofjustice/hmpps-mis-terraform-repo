locals {
  lb_name     = "${local.short_environment_identifier}-${local.nart_role}"
  lb_endpoint = "ndl-dfi"
  external_lb_security_groups = flatten([data.terraform_remote_state.security-groups.outputs.security_groups_sg_mis_app_lb])
}

############################################
# CREATE LB FOR dfi
############################################

# elb
module "create_app_elb" {
  source                      = "../modules/create_elb_with_https"
  name                        = local.lb_name
  subnets                     = local.public_subnet_ids
  security_groups             = local.external_lb_security_groups
  internal                    = false
  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout
  bucket                      = local.logs_bucket
  bucket_prefix               = local.lb_name
  interval                    = 60
  ssl_certificate_id          = local.certificate_arn
  instance_port               = local.dfi_port
  instance_protocol           = "http"
  lb_port                     = 80
  lb_port_https               = 443
  lb_protocol                 = "http"
  lb_protocol_https           = "https"
  target                      = "HTTP:8080/DataServices/"
  tags                        = local.tags
}

###############################################
# Create route53 entry for case notes lb
###############################################

resource "aws_route53_record" "dns_entry" {
  zone_id = local.public_zone_id
  name    = "${local.lb_endpoint}.${local.external_domain}"
  type    = "A"

  alias {
    name                   = module.create_app_elb.environment_elb_dns_name
    zone_id                = module.create_app_elb.environment_elb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_cookie_stickiness_policy" "dfi" {
  name          = "dfi-policy"
  load_balancer = module.create_app_elb.environment_elb_name
  lb_port       = 443
}
