#-------------------------------------------------------------
### Getting ACM Cert
#-------------------------------------------------------------
data "aws_acm_certificate" "cert" {
  domain      = "*.${data.terraform_remote_state.common.external_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

####################################################
# Locals
####################################################

locals {
  certificate_arn      = "${data.aws_acm_certificate.cert.arn}"
  lb_name              = "${local.short_environment_identifier}-proxy"
  lb_security_groups   = ["${data.terraform_remote_state.security-groups.security_groups_sg_ldap_lb}"]
  access_logs_bucket   = "${data.terraform_remote_state.common.common_s3_lb_logs_bucket}"
  public_zone_id       = "${data.terraform_remote_state.common.public_zone_id}"
  application_endpoint = "auth"
  external_domain      = "${data.terraform_remote_state.common.external_domain}"
  ebs_device_name      = "/dev/xvdb"
  keys_dir             = "/opt/keys"

  self_signed_ssm = {
    ca_cert = "${data.terraform_remote_state.self_certs.self_signed_ca_ssm_cert_pem_name}"
    cert    = "${data.terraform_remote_state.self_certs.self_signed_server_ssm_cert_pem_name}"
    key     = "${data.terraform_remote_state.self_certs.self_signed_server_ssm_private_key_name}"
  }
}

############################################
# CREATE LB FOR HTTPD
############################################

# elb
module "create_app_elb" {
  source          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=issue-118//modules//loadbalancer//elb//create_elb_with_https"
  name            = "${local.lb_name}-ext"
  subnets         = ["${local.public_subnet_ids}"]
  security_groups = ["${local.lb_security_groups}"]
  internal        = "${var.internal}"

  cross_zone_load_balancing   = "${var.cross_zone_load_balancing}"
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"
  bucket                      = "${local.access_logs_bucket}"
  bucket_prefix               = "${local.lb_name}"
  interval                    = 60
  ssl_certificate_id          = "${local.certificate_arn}"
  instance_port               = 80
  instance_protocol           = "http"
  lb_port                     = 80
  lb_port_https               = 443
  lb_protocol                 = "http"
  lb_protocol_https           = "https"
  health_check                = ["${var.health_check}"]
  https_instance_port         = "443"
  https_instance_protocol     = "https"
  tags                        = "${local.tags}"
}

###############################################
# Create route53 entry for httpd lb
###############################################

resource "aws_route53_record" "dns_entry" {
  zone_id = "${local.public_zone_id}"
  name    = "${local.application_endpoint}.${local.external_domain}"
  type    = "A"

  alias {
    name                   = "${module.create_app_elb.environment_elb_dns_name}"
    zone_id                = "${module.create_app_elb.environment_elb_zone_id}"
    evaluate_target_health = false
  }
}

############################################
# CREATE LOG GROUPS FOR CONTAINER LOGS
############################################

module "create_loggroup_proxy" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//cloudwatch//loggroup"
  log_group_path           = "${local.environment_identifier}"
  loggroupname             = "ldap-${local.application_endpoint}-proxy"
  cloudwatch_log_retention = "${var.cloudwatch_log_retention}"
  tags                     = "${local.tags}"
}

############################################
# CREATE USER DATA FOR EC2 RUNNING SERVICES
############################################

data "template_file" "user_data" {
  template = "${file("./userdata/proxy-userdata.sh")}"

  vars {
    keys_dir             = "${local.keys_dir}"
    ebs_device_name      = "${local.ebs_device_name}"
    app_name             = "proxy"
    env_identifier       = "${local.environment_identifier}"
    short_env_identifier = "${local.short_environment_identifier}"
    log_group_name       = "${module.create_loggroup_proxy.loggroup_name}"
    container_name       = "proxy"
    image_url            = "httpd"
    image_version        = "latest"
    self_signed_ca_cert  = "${local.self_signed_ssm["ca_cert"]}"
    self_signed_cert     = "${local.self_signed_ssm["cert"]}"
    self_signed_key      = "${local.self_signed_ssm["key"]}"
    ssm_get_command      = "aws --region ${local.region} ssm get-parameters --names"
    s3_bucket_config     = "${local.s3bucket}"
    external_domain      = "${local.external_domain}"
    internal_domain      = "${local.internal_domain}"
    route53_sub_domain   = "proxy.${local.environment}"
    bastion_inventory    = "${local.bastion_inventory}"
    account_id           = "${local.account_id}"
    application_endpoint = "${local.application_endpoint}"
  }
}

############################################
# CREATE LAUNCH CONFIG FOR EC2 RUNNING SERVICES
############################################

module "launch_cfg" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//launch_configuration//blockdevice"
  launch_configuration_name   = "${local.common_name}-proxy"
  image_id                    = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${local.proxy_instance_type}"
  volume_size                 = "30"
  instance_profile            = "${local.instance_profile}"
  key_name                    = "${local.ssh_deployer_key}"
  ebs_device_name             = "${local.ebs_device_name}"
  ebs_volume_type             = "standard"
  ebs_volume_size             = "10"
  ebs_encrypted               = "true"
  associate_public_ip_address = false

  security_groups = [
    "${local.sg_outbound_id}",
    "${local.sg_map_ids["sg_mis_common"]}",
    "${local.sg_map_ids["sg_ldap_proxy"]}",
  ]

  user_data = "${data.template_file.user_data.rendered}"
}

module "auto_scale" {
  source               = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//autoscaling//group//asg_classic_lb"
  asg_name             = "${local.lb_name}"
  subnet_ids           = ["${local.private_subnet_ids}"]
  asg_min              = "1"
  asg_max              = "1"
  asg_desired          = "1"
  launch_configuration = "${module.launch_cfg.launch_name}"
  load_balancers       = ["${module.create_app_elb.environment_elb_name}"]
  tags                 = "${local.tags}"
}
