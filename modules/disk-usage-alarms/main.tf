#---------------------------------------------------------------------
# Warning level Alarms
#---------------------------------------------------------------------


resource "aws_cloudwatch_metric_alarm" "free-disk-space-D-alert" {
  count = length(
    var.instance_ids,
  )
  alarm_name          = "${var.environment_name}__Free-Space-D-Drive__alert__${var.component}__${var.instance_ids[count.index]}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "LogicalDisk % Free Space"
  namespace           = "CWAgent"
  period              = var.period
  statistic           = "Average"
  threshold           = var.alert_threshold
  alarm_description   = "D: Drive Free Space is less than ${var.alert_threshold}% for ${var.primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [var.sns_topic]
  ok_actions          = [var.sns_topic]
  tags                = var.tags

  dimensions = {
    instance     = "D:"
    InstanceId   = var.instance_ids[count.index]
    ImageId      = var.ami_id[count.index]
    objectname   = var.objectname
    InstanceType = var.instance_type[count.index]
  }
}


resource "aws_cloudwatch_metric_alarm" "free-disk-space-C-alert" {
  count = length(
    var.instance_ids,
  )
  alarm_name          = "${var.environment_name}__Free-Space-C-Drive__alert__${var.component}__${var.instance_ids[count.index]}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "LogicalDisk % Free Space"
  namespace           = "CWAgent"
  period              = var.period
  statistic           = "Average"
  threshold           = var.alert_threshold
  alarm_description   = "C: Drive Free Space is less than ${var.alert_threshold}% for ${var.primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [var.sns_topic]
  ok_actions          = [var.sns_topic]
  tags                = var.tags

  dimensions = {
    instance     = "C:"
    InstanceId   = var.instance_ids[count.index]
    ImageId      = var.ami_id[count.index]
    objectname   = var.objectname
    InstanceType = var.instance_type[count.index]
  }
}



#---------------------------------------------------------------------
# CRITICAL Level Alarms
#---------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "free-disk-space-D-critical" {
  count = length(
    var.instance_ids,
  )
  alarm_name          = "${var.environment_name}__Free-Space-D-Drive__critical__${var.component}__${var.instance_ids[count.index]}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "LogicalDisk % Free Space"
  namespace           = "CWAgent"
  period              = var.period
  statistic           = "Average"
  threshold           = var.critical_threshold
  alarm_description   = "D: Drive Free Space is less than ${var.critical_threshold}% for ${var.primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [var.sns_topic]
  ok_actions          = [var.sns_topic]
  tags                = var.tags

  dimensions = {
    instance     = "D:"
    InstanceId   = var.instance_ids[count.index]
    ImageId      = var.ami_id[count.index]
    objectname   = var.objectname
    InstanceType = var.instance_type[count.index]
  }
}


resource "aws_cloudwatch_metric_alarm" "free-disk-space-C-critical" {
  count = length(
    var.instance_ids,
  )
  alarm_name          = "${var.environment_name}__Free-Space-C-Drive__critical__${var.component}__${var.instance_ids[count.index]}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "LogicalDisk % Free Space"
  namespace           = "CWAgent"
  period              = var.period
  statistic           = "Average"
  threshold           = var.critical_threshold
  alarm_description   = "C: Drive Free Space is less than ${var.critical_threshold}% for ${var.primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
  alarm_actions       = [var.sns_topic]
  ok_actions          = [var.sns_topic]
  tags                = var.tags

  dimensions = {
    instance     = "C:"
    InstanceId   = var.instance_ids[count.index]
    ImageId      = var.ami_id[count.index]
    objectname   = var.objectname
    InstanceType = var.instance_type[count.index]
  }
}
