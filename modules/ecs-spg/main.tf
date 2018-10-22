# LOCALS 

locals {
  common_name                  = "${var.environment_identifier}-${var.app_hostnames["external"]}"
  application_endpoint         = "${var.app_hostnames["external"]}"
  short_environment_identifier = "${var.short_environment_identifier}-${var.app_name}"
  vpc_id                       = "${var.vpc_id}"
  config_bucket                = "${var.config_bucket}"
  public_subnet_ids            = ["${var.public_subnet_ids}"]
  lb_security_groups           = ["${var.lb_security_groups}"]
  certificate_arn              = ["${var.certificate_arn}"]
  access_logs_bucket           = "${var.access_logs_bucket}"
  public_zone_id               = "${var.public_zone_id}"
  external_domain              = "${var.external_domain}"
  instance_security_groups     = ["${var.instance_security_groups}"]
  artefact-bucket              = "${var.artefact-bucket}"
}

############################################
# CREATE LB FOR spg
############################################
module "create_app_alb" {
  source          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//create_lb"
  lb_name         = "${local.short_environment_identifier}-ext"
  subnet_ids      = ["${local.public_subnet_ids}"]
  s3_bucket_name  = "${local.access_logs_bucket}"
  security_groups = ["${local.lb_security_groups}"]
  tags            = "${var.tags}"

  internal = false
}

###############################################
# Create route53 entry for spg lb
###############################################

resource "aws_route53_record" "dns_entry" {
  zone_id = "${local.public_zone_id}"
  name    = "${local.application_endpoint}.${local.external_domain}"
  type    = "A"

  alias {
    name                   = "${module.create_app_alb.lb_dns_name}"
    zone_id                = "${module.create_app_alb.lb_zone_id}"
    evaluate_target_health = false
  }
}

#-------------------------------------------------------------
### Create app listeners
#-------------------------------------------------------------

module "create_app_alb_listener_with_https" {
  source           = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//create_listener_with_https"
  lb_port          = "${var.alb_backend_port}"
  lb_protocol      = "${var.alb_listener_protocol}"
  lb_arn           = "${module.create_app_alb.lb_arn}"
  target_group_arn = "${module.create_app_alb_targetgrp.target_group_arn}"
  ssl_policy       = "${var.public_ssl_policy}"
  certificate_arn  = ["${local.certificate_arn}"]
}

module "create_app_alb_listener" {
  source           = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//create_listener"
  lb_port          = "${var.alb_http_port}"
  lb_protocol      = "HTTP"
  lb_arn           = "${module.create_app_alb.lb_arn}"
  target_group_arn = "${module.create_app_alb_targetgrp.target_group_arn}"
}

############################################
# CREATE TARGET GROUPS FOR APP PORTS
############################################

module "create_app_alb_targetgrp" {
  source               = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//targetgroup"
  appname              = "${local.short_environment_identifier}-ext"
  target_port          = "${var.backend_app_port}"
  target_protocol      = "${var.backend_app_protocol}"
  vpc_id               = "${var.vpc_id}"
  check_interval       = "${var.backend_check_interval}"
  check_path           = "${var.backend_check_app_path}"
  check_port           = "${var.backend_app_port}"
  check_protocol       = "${var.backend_app_protocol}"
  timeout              = "${var.backend_timeout}"
  healthy_threshold    = "${var.backend_healthy_threshold}"
  unhealthy_threshold  = "${var.backend_unhealthy_threshold}"
  return_code          = "${var.backend_return_code}"
  deregistration_delay = "${var.deregistration_delay}"
  target_type          = "${var.target_type}"
  tags                 = "${var.tags}"
}

############################################
# CREATE ECS CLUSTER FOR spg
############################################
# ##### ECS Cluster

module "ecs_cluster" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ecs//ecs_cluster"
  cluster_name = "${local.common_name}"
}

############################################
# CREATE LOG GROUPS FOR CONTAINER LOGS
############################################

module "create_loggroup" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//cloudwatch//loggroup"
  log_group_path           = "${var.environment_identifier}"
  loggroupname             = "${var.app_name}"
  cloudwatch_log_retention = "${var.cloudwatch_log_retention}"
  tags                     = "${var.tags}"
}

############################################
# CREATE ECS TASK DEFINTIONS
############################################

data "aws_ecs_task_definition" "app_task_definition" {
  task_definition = "${module.app_task_definition.task_definition_family}"
  depends_on      = ["module.app_task_definition"]
}

data "template_file" "app_task_definition" {
  template = "${file("task_definitions/${var.backend_app_template_file}")}"

  vars {
    container_name        = "${var.app_name}"
    cpu_units             = "${var.backend_ecs_cpu_units}"
    data_volume_host_path = "${var.keys_dir}"
    data_volume_name      = "key_dir"
    environment           = "${var.environment}"
    image_url             = "${var.image_url}"
    log_group_name        = "${module.create_loggroup.loggroup_name}"
    log_group_region      = "${var.region}"
    memory                = "${var.backend_ecs_memory}"
    spg_build_inv_dir     = "${var.build_inv_dir}"
    spg_build_s3_repo     = "${local.artefact-bucket}"
    version               = "${var.image_version}"
  }
}

module "app_task_definition" {
  source   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ecs//ecs-taskdefinitions//appwith_single_volume"
  app_name = "${local.common_name}"

  container_name        = "${var.app_name}"
  container_definitions = "${data.template_file.app_task_definition.rendered}"

  data_volume_name      = "key_dir"
  data_volume_host_path = "${var.keys_dir}"
}

############################################
# CREATE ECS SERVICES
############################################

module "app_service" {
  source                          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ecs/ecs_service//withloadbalancer//alb"
  servicename                     = "${local.common_name}"
  clustername                     = "${module.ecs_cluster.ecs_cluster_id}"
  ecs_service_role                = "${var.ecs_service_role}"
  target_group_arn                = "${module.create_app_alb_targetgrp.target_group_arn}"
  containername                   = "${var.app_name}"
  containerport                   = "${var.backend_app_port}"
  task_definition_family          = "${module.app_task_definition.task_definition_family}"
  task_definition_revision        = "${module.app_task_definition.task_definition_revision}"
  current_task_definition_version = "${data.aws_ecs_task_definition.app_task_definition.revision}"
  service_desired_count           = "${var.service_desired_count}"
}

############################################
# CREATE USER DATA FOR EC2 RUNNING SERVICES
############################################

data "template_file" "user_data" {
  template = "${file("${var.user_data}")}"

  vars {
    keys_dir             = "${var.cache_home}"
    ebs_device           = "${var.ebs_device_name}"
    app_name             = "${var.app_name}"
    env_identifier       = "${var.environment_identifier}"
    short_env_identifier = "${var.short_environment_identifier}"
    cluster_name         = "${module.ecs_cluster.ecs_cluster_name}"
    log_group_name       = "${module.create_loggroup.loggroup_name}"
    container_name       = "${var.app_name}"
    keys_dir             = "${var.keys_dir}"
  }
}

############################################
# CREATE LAUNCH CONFIG FOR EC2 RUNNING SERVICES
############################################

module "launch_cfg" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//launch_configuration//blockdevice"
  launch_configuration_name   = "${local.common_name}"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  volume_size                 = "${var.volume_size}"
  instance_profile            = "${var.instance_profile}"
  key_name                    = "${var.ssh_deployer_key}"
  ebs_device_name             = "${var.ebs_device_name}"
  ebs_volume_type             = "${var.ebs_volume_type}"
  ebs_volume_size             = "${var.ebs_volume_size}"
  ebs_encrypted               = "${var.ebs_encrypted}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  security_groups             = ["${local.instance_security_groups}"]
  user_data                   = "${data.template_file.user_data.rendered}"
}

############################################
# CREATE AUTO SCALING GROUP
############################################

module "auto_scale" {
  source               = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//autoscaling//group//default"
  asg_name             = "${local.common_name}"
  subnet_ids           = ["${local.public_subnet_ids}"]
  asg_min              = "${var.asg_min}"
  asg_max              = "${var.asg_max}"
  asg_desired          = "${var.asg_desired}"
  launch_configuration = "${module.launch_cfg.launch_name}"
  tags                 = "${var.tags}"
}

############################################
# UPLOAD TO S3
############################################


# resource "aws_s3_bucket_object" "nginx_bucket_object" {
#   key    = "${local.common_name}/config/nginx.conf"
#   bucket = "${local.config_bucket}"
#   source = "./templates/nginx.conf"
#   etag   = "${md5(file("./templates/nginx.conf"))}"
# }

