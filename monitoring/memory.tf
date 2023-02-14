### Memory Alarms critical

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_instance-memory-critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids,
  )
  alarm_name          = "${var.environment_type}__Memory-Utilization__critical__BWS__${data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bws.outputs.bws_primary_dns_ext[count.index]}. Please contact the MIS Team or the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags


  dimensions = {
    InstanceId   = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids[count.index]
    ImageId      = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_ami_id[count.index]
    InstanceType = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_type[count.index]
    objectname   = "Memory"
  }
}

#BCS
resource "aws_cloudwatch_metric_alarm" "bcs_instance-memory-critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids,
  )
  alarm_name          = "${var.environment_type}__Memory-Utilization__critical__BCS__${data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId   = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids[count.index]
    ImageId      = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_ami_id[count.index]
    InstanceType = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_type[count.index]
    objectname   = "Memory"
  }
}

#BPS
resource "aws_cloudwatch_metric_alarm" "bps_instance-memory-critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids,
  )
  alarm_name          = "${var.environment_type}__Memory-Utilization__critical__BPS__${data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bps.outputs.bps_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId   = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids[count.index]
    ImageId      = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_ami_id[count.index]
    InstanceType = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_type[count.index]
    objectname   = "Memory"
  }
}

#DIS
resource "aws_cloudwatch_metric_alarm" "dis_instance-memory-critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids,
  )
  alarm_name          = "${var.environment_type}__Memory-Utilization__critical__DIS__${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId   = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]
    ImageId      = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_ami_id[count.index]
    InstanceType = var.dis_instance_type
    objectname   = "Memory"
  }
}
# DIS 
# Create a second alarm for DIS Memory Utilization in order to consider the daily changes in ec2 type due to the resizing ETL scheduler. Alarm created in  mis-dev and prod only as scheduler applied in these two envs.
resource "aws_cloudwatch_metric_alarm" "dis_instance-memory-critical-2" {
  count               = (var.environment_type == "mis-dev" || var.environment_type == "prod") ?  length(data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids) : 0
  
  alarm_name          = "${var.environment_type}__Memory-Utilization__critical__DIS__2__${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId   = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]
    ImageId      = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_ami_id[count.index]
    InstanceType = var.dis_instance_type_lower
    objectname   = "Memory"
  }
}

