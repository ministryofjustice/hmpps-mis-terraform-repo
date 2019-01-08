############################################
# CREATE LOG GROUPS FOR CONTAINER LOGS
############################################

module "create_loggroup" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//cloudwatch//loggroup"
  log_group_path           = "${local.environment_identifier}"
  loggroupname             = "ldap"
  cloudwatch_log_retention = "${local.cloudwatch_log_retention}"
  tags                     = "${local.tags}"
}

#-------------------------------------------------------------
### Create primary 
#-------------------------------------------------------------

data "template_file" "primary_userdata" {
  template = "${file("./userdata/primary-userdata.sh")}"

  vars {
    app_name             = "${local.app_name}"
    bastion_inventory    = "${local.bastion_inventory}"
    env_identifier       = "${local.environment_identifier}"
    short_env_identifier = "${local.short_environment_identifier}"
    route53_sub_domain   = "${local.environment}.${local.app_name}"
    private_domain       = "${local.internal_domain}"
    account_id           = "${local.account_id}"
    internal_domain      = "${local.internal_domain}"
    environment          = "${local.environment}"
    ldap_role            = "${local.ldap_primary}"
    hostname             = "${local.ldap_primary}.${local.internal_domain}"
    common_name          = "${local.common_name}"
    s3bucket             = "${local.s3bucket}"
    log_group_name       = "${module.create_loggroup.loggroup_name}"
  }
}

module "ldap-primary" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ec2"
  app_name                    = "${local.common_name}-${local.ldap_primary}-01"
  ami_id                      = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${local.private_subnet_map["az1"]}"
  iam_instance_profile        = "${local.instance_profile}"
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = "${data.template_file.primary_userdata.rendered}"
  CreateSnapshot              = false
  tags                        = "${local.tags}"
  key_name                    = "${local.ssh_deployer_key}"
  root_device_size            = "30"

  vpc_security_group_ids = [
    "${local.sg_outbound_id}",
    "${local.sg_map_ids["sg_mis_common"]}",
    "${local.sg_map_ids["sg_ldap_inst"]}",
  ]
}

#-------------------------------------------------------------
# Create route53 entry for instance 1
#-------------------------------------------------------------

resource "aws_route53_record" "ldap-primary" {
  zone_id = "${local.private_zone_id}"
  name    = "${local.ldap_primary}.${local.internal_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${module.ldap-primary.private_ip}"]
}

#-------------------------------------------------------------
### Create replica 
#-------------------------------------------------------------
data "template_file" "replica_userdata" {
  template = "${file("./userdata/replica-userdata.sh")}"

  vars {
    app_name             = "${local.app_name}"
    bastion_inventory    = "${local.bastion_inventory}"
    env_identifier       = "${local.environment_identifier}"
    short_env_identifier = "${local.short_environment_identifier}"
    route53_sub_domain   = "${local.environment}.${local.app_name}"
    private_domain       = "${local.internal_domain}"
    account_id           = "${local.account_id}"
    internal_domain      = "${local.internal_domain}"
    environment          = "${local.environment}"
    ldap_role            = "${local.ldap_replica}"
    hostname             = "${local.ldap_replica}.${local.internal_domain}"
    common_name          = "${local.common_name}"
    s3bucket             = "${local.s3bucket}"
    log_group_name       = "${module.create_loggroup.loggroup_name}"
  }
}

module "ldap-replica" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ec2"
  app_name                    = "${local.common_name}-${local.ldap_replica}-01"
  ami_id                      = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${local.private_subnet_map["az2"]}"
  iam_instance_profile        = "${local.instance_profile}"
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = "${data.template_file.replica_userdata.rendered}"
  CreateSnapshot              = false
  tags                        = "${local.tags}"
  key_name                    = "${local.ssh_deployer_key}"
  root_device_size            = "30"

  vpc_security_group_ids = [
    "${local.sg_outbound_id}",
    "${local.sg_map_ids["sg_mis_common"]}",
    "${local.sg_map_ids["sg_ldap_inst"]}",
  ]
}

#-------------------------------------------------------------
# Create route53 entry for replica
#-------------------------------------------------------------

resource "aws_route53_record" "ldap-replica" {
  zone_id = "${local.private_zone_id}"
  name    = "${local.ldap_replica}.${local.internal_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${module.ldap-replica.private_ip}"]
}
