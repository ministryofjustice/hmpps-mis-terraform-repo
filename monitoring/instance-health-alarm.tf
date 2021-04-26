### HealthCheck Alarms

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_instance-health-check" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids,
  )
  alarm_name          = "${local.environment_name}__StatusCheckFailed__critical__BWS__${data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "EC2 Health status failed for ${data.terraform_remote_state.ec2-ndl-bws.outputs.bws_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-bws.outputs.bws_instance_ids[count.index]
  }
}

#BCS
resource "aws_cloudwatch_metric_alarm" "bcs_instance-health-check" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids,
  )
  alarm_name          = "${local.environment_name}__StatusCheckFailed__critical__BCS__${data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "EC2 Health status failed for ${data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-bcs.outputs.bcs_instance_ids[count.index]
  }
}

#BPS
resource "aws_cloudwatch_metric_alarm" "bps_instance-health-check" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids,
  )
  alarm_name          = "${local.environment_name}__StatusCheckFailed__critical__BPS__${data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "EC2 Health status failed for ${data.terraform_remote_state.ec2-ndl-bps.outputs.bps_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-bps.outputs.bps_instance_ids[count.index]
  }
}

#DIS
resource "aws_cloudwatch_metric_alarm" "dis_instance-health-check" {
  count = length(
    data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids,
  )
  alarm_name          = "${local.environment_name}__StatusCheckFailed__critical__DIS__${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "EC2 Health status failed for ${data.terraform_remote_state.ec2-ndl-dis.outputs.dis_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-dis.outputs.dis_instance_ids[count.index]
  }
}

#BFS
resource "aws_cloudwatch_metric_alarm" "bfs_instance-health-check" {
  count = length(
    data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids,
  )
  alarm_name          = "${local.environment_name}__StatusCheckFailed__critical__BFS__${data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "EC2 Health status failed for ${data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    InstanceId = data.terraform_remote_state.ec2-ndl-bfs.outputs.bfs_instance_ids[count.index]
  }
}
