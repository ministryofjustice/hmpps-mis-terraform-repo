### Memory Alarms critical

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_instance-memory-critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids,
  )
  alarm_name          = "${local.environment_name}__Memory-Utilization__critical__BWS__${data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids[count.index]}"
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
  alarm_name          = "${local.environment_name}__Memory-Utilization__critical__BCS__${data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids[count.index]}"
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
  alarm_name          = "${local.environment_name}__Memory-Utilization__critical__BPS__${data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids[count.index]}"
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
  alarm_name          = "${local.environment_name}__Memory-Utilization__critical__DIS__${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]}"
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
    InstanceType = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_type[count.index]
    objectname   = "Memory"
  }
}

#BFS
resource "aws_cloudwatch_metric_alarm" "bfs_instance-memory-critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids,
  )
  alarm_name          = "${local.environment_name}__Memory-Utilization__critical__BFS__${data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId   = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids[count.index]
    ImageId      = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_ami_id[count.index]
    InstanceType = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_type[count.index]
    objectname   = "Memory"
  }
}
