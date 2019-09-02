locals {
  lb_name     = "${local.short_environment_identifier}-${local.nart_role}"
  lb_endpoint = "ndl-bws"

  external_lb_security_groups = [
    "${data.terraform_remote_state.security-groups.security_groups_sg_mis_app_lb}",
  ]
}

############################################
# CREATE LB FOR case notes
############################################

# elb
module "create_app_elb" {
  source          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//elb//create_elb_with_https"
  name            = "${local.lb_name}"
  subnets         = ["${local.public_subnet_ids}"]
  security_groups = ["${local.external_lb_security_groups}"]
  internal        = false

  cross_zone_load_balancing   = "${var.cross_zone_load_balancing}"
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"
  bucket                      = "${local.logs_bucket}"
  bucket_prefix               = "${local.lb_name}"
  interval                    = 60
  ssl_certificate_id          = "${local.certificate_arn}"
  instance_port               = "${local.bws_port}"
  instance_protocol           = "http"
  lb_port                     = 80
  lb_port_https               = 443
  lb_protocol                 = "http"
  lb_protocol_https           = "https"
  health_check                = ["${var.bws-health_check}"]
  tags                        = "${local.tags}"
}

###############################################
# Create route53 entry for case notes lb
###############################################

resource "aws_route53_record" "dns_entry" {
  zone_id = "${local.public_zone_id}"
  name    = "${local.lb_endpoint}.${local.external_domain}"
  type    = "A"

  alias {
    name                   = "${module.create_app_elb.environment_elb_dns_name}"
    zone_id                = "${module.create_app_elb.environment_elb_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_lb_cookie_stickiness_policy" "bws" {
  name                     = "bws-policy"
  load_balancer            = "${module.create_app_elb.id}"
  lb_port                  = 443
  cookie_expiration_period = 300
}


###############################################
# Elb attachment
###############################################

# elb attachment is done after ec2 creation
# module "create_app_elb_attachment" {
#   source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//elb//elb_attachment"
#   number_of_instances = "1"
#   elb                 = "${module.create_app_elb.environment_elb_name}"
#   instances           = "${aws_instance.bws_server.*.private_ip}"
# }
