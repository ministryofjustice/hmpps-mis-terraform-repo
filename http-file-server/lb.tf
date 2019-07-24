locals {
  lb_name     = "${local.short_environment_identifier}-${local.app_name}"


  internal_lb_security_groups = [
    "${data.terraform_remote_state.security-groups.sg_mis_httpfs_lb}",
  ]
}

############################################
# CREATE LB HTTP FS
############################################

# elb
module "http_fs_lb" {
  source          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//elb//create_elb_with_https"
  name            = "${local.lb_name}-elb"
  subnets         = ["${local.public_subnet_ids}"]
  security_groups = ["${local.internal_lb_security_groups}"]
  internal        = false

  cross_zone_load_balancing   = "${var.cross_zone_load_balancing}"
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"
  bucket                      = "${local.logs_bucket}"
  bucket_prefix               = "${local.lb_name}"
  interval                    = 60
  ssl_certificate_id          = "${local.certificate_arn}"
  instance_port               = "80"
  instance_protocol           = "http"
  lb_port                     = 80
  lb_port_https               = 443
  lb_protocol                 = "http"
  lb_protocol_https           = "https"
  health_check                = ["${var.httpfs_health_check}"]
  tags                        = "${local.tags}"
}

###############################################
# Create route53 entry
###############################################

resource "aws_route53_record" "dns_entry" {
  zone_id = "${local.public_zone_id}"
  name    = "fileshare.${local.external_domain}"
  type    = "A"

  alias {
    name                   = "${module.http_fs_lb.environment_elb_dns_name}"
    zone_id                = "${module.http_fs_lb.environment_elb_zone_id}"
    evaluate_target_health = false
  }
}
