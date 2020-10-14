############################################
# CREATE LB Nextcloud
############################################

# elb
module "nextcloud_lb" {
  source                      = "../modules/create_elb_with_https"
  name                        = "${local.lb_name}-elb"
  subnets                     = local.public_subnet_ids
  security_groups             = local.internal_lb_security_groups
  internal                    = false
  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout
  bucket                      = local.logs_bucket
  bucket_prefix               = local.lb_name
  interval                    = 60
  ssl_certificate_id          = local.certificate_arn
  instance_port               = "80"
  instance_protocol           = "http"
  lb_port                     = 80
  lb_port_https               = 443
  lb_protocol                 = "http"
  lb_protocol_https           = "https"
  target                      = "HTTP:80/index.php/login"
  tags                        = var.tags
}

###############################################
# Create policies
###############################################
resource "aws_lb_cookie_stickiness_policy" "nextcloud" {
  name                     = "nextcloud-policy"
  load_balancer            = module.nextcloud_lb.environment_elb_name
  lb_port                  = 443
  cookie_expiration_period = 300
}

resource "aws_proxy_protocol_policy" "nextcloud" {
  load_balancer  = module.nextcloud_lb.environment_elb_name
  instance_ports = ["80"]
}

###############################################
# Create route53 entry
###############################################

resource "aws_route53_record" "dns_entry" {
  zone_id = local.public_zone_id
  name    = "${local.app_name}.${local.external_domain}"
  type    = "A"

  alias {
    name                   = module.nextcloud_lb.environment_elb_dns_name
    zone_id                = module.nextcloud_lb.environment_elb_zone_id
    evaluate_target_health = false
  }
}
