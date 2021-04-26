locals {

sns_topic           = aws_sns_topic.alarm_notification.arn
##DIS
dis_instance_ids    = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids
dis_primary_dns_ext = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_primary_dns_ext
dis_ami_id          = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_ami_id
dis_instance_type   = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_type

#BPS
bps_instance_ids    = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids
bps_primary_dns_ext = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_primary_dns_ext
bps_ami_id          = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_ami_id
bps_instance_type   = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_type

##BCS
bcs_instance_ids    = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids
bcs_primary_dns_ext = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_primary_dns_ext
bcs_ami_id          = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_ami_id
bcs_instance_type   = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_type

##BFS
bfs_instance_ids    = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids
bfs_primary_dns_ext = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_primary_dns_ext
bfs_ami_id          = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_ami_id
bfs_instance_type   = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_type

##BWS
bws_instance_ids    = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids
bws_primary_dns_ext = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_primary_dns_ext
bws_ami_id          = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_ami_id
bws_instance_type   = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_type
}


module "dis" {
  source             = "../modules/disk-usage-alarms/"
  component          = "DIS"
  objectname         = "LogicalDisk"
  alert_threshold    = "25"
  critical_threshold = "5"
  period             = "60"
  environment_name   = local.environment_name
  instance_ids       = local.dis_instance_ids
  primary_dns_ext    = local.dis_primary_dns_ext
  ami_id             = local.dis_ami_id
  instance_type      = local.dis_instance_type
  sns_topic          = local.sns_topic
  tags               = local.tags
}

module "bps" {
  source             = "../modules/disk-usage-alarms/"
  component          = "BPS"
  objectname         = "LogicalDisk"
  alert_threshold    = "25"
  critical_threshold = "5"
  period             = "60"
  environment_name   = local.environment_name
  instance_ids       = local.bps_instance_ids
  primary_dns_ext    = local.bps_primary_dns_ext
  ami_id             = local.bps_ami_id
  instance_type      = local.bps_instance_type
  sns_topic          = local.sns_topic
  tags               = local.tags
}

module "bcs" {
  source             = "../modules/disk-usage-alarms/"
  component          = "BCS"
  objectname         = "LogicalDisk"
  alert_threshold    = "25"
  critical_threshold = "5"
  period             = "60"
  environment_name   = local.environment_name
  instance_ids       = local.bcs_instance_ids
  primary_dns_ext    = local.bcs_primary_dns_ext
  ami_id             = local.bcs_ami_id
  instance_type      = local.bcs_instance_type
  sns_topic          = local.sns_topic
  tags               = local.tags
}

module "bfs" {
  source             = "../modules/disk-usage-alarms/"
  component          = "BFS"
  objectname         = "LogicalDisk"
  alert_threshold    = "25"
  critical_threshold = "5"
  period             = "60"
  environment_name   = local.environment_name
  instance_ids       = local.bfs_instance_ids
  primary_dns_ext    = local.bfs_primary_dns_ext
  ami_id             = local.bfs_ami_id
  instance_type      = local.bfs_instance_type
  sns_topic          = local.sns_topic
  tags               = local.tags
}

module "bws" {
  source             = "../modules/disk-usage-alarms/"
  component          = "BWS"
  objectname         = "LogicalDisk"
  alert_threshold    = "25"
  critical_threshold = "5"
  period             = "60"
  environment_name   = local.environment_name
  instance_ids       = local.bws_instance_ids
  primary_dns_ext    = local.bws_primary_dns_ext
  ami_id             = local.bws_ami_id
  instance_type      = local.bws_instance_type
  sns_topic          = local.sns_topic
  tags               = local.tags
}
