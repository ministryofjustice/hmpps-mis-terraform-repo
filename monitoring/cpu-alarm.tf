### CPU Alarms critical Level

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_cpu_critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids,
  )
  alarm_name          = "${local.environment_name}__CPU-Utilization__critical__BWS__${data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bws.outputs.bws_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids[count.index]
  }
}

#dis
resource "aws_cloudwatch_metric_alarm" "dis_cpu_critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids,
  )
  alarm_name          = "${local.environment_name}__CPU-Utilization__critical__DIS__${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_primary_dns_ext[count.index]}. Please note: During the ETL Run it is normal for resource usage to be high, daily between 18:30-00:00 & 01:00-05:30 when this can be ignored. Otherwise contact the MIS Team or AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]
  }
}

#bps
resource "aws_cloudwatch_metric_alarm" "bps_cpu_critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids,
  )
  alarm_name          = "${local.environment_name}__CPU-Utilization__critical__BPS__${data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bps.outputs.bps_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids[count.index]
  }
}

#bcs
resource "aws_cloudwatch_metric_alarm" "bcs_cpu_critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids,
  )
  alarm_name          = "${local.environment_name}__CPU-Utilization__critical__BCS__${data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids[count.index]
  }
}

#bfs
resource "aws_cloudwatch_metric_alarm" "bfs_cpu_critical" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids,
  )
  alarm_name          = "${local.environment_name}__CPU-Utilization__critical__BFS__${data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "92"
  alarm_description   = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bps.outputs.bps_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids[count.index]
  }
}
