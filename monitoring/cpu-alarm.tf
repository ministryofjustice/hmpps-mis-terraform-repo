### CPU Alarms Alert Level

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_cpu_alert" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__alert__BWS__${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "85"
  alarm_description         = "CPU utilization is averaging 85% for ${data.terraform_remote_state.ec2-ndl-bws.bws_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  }
}


#dis
resource "aws_cloudwatch_metric_alarm" "dis_cpu_alert" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__alert__DIS__${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "85"
  alarm_description         = "CPU utilization is averaging 85% for ${data.terraform_remote_state.ec2-ndl-dis.dis_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  }
}


#bps
resource "aws_cloudwatch_metric_alarm" "bps_cpu_alert" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__alert__BPS__${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "85"
  alarm_description         = "CPU utilization is averaging 85% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  }
}


#bcs
resource "aws_cloudwatch_metric_alarm" "bcs_cpu_alert" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__alert__BCS__${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "85"
  alarm_description         = "CPU utilization is averaging 85% for ${data.terraform_remote_state.ec2-ndl-bcs.bcs_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  }
}


#bfs
resource "aws_cloudwatch_metric_alarm" "bfs_cpu_alert" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__alert__BFS__${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "85"
  alarm_description         = "CPU utilization is averaging 85% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  }
}

### CPU Alarms severe Level

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_cpu_severe" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe__BWS__${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = "CPU utilization is averaging 90% for ${data.terraform_remote_state.ec2-ndl-bws.bws_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  }
}


#dis
resource "aws_cloudwatch_metric_alarm" "dis_cpu_severe" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe__DIS__${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = "CPU utilization is averaging 90% for ${data.terraform_remote_state.ec2-ndl-dis.dis_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  }
}


#bps
resource "aws_cloudwatch_metric_alarm" "bps_cpu_severe" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe__BPS__${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = "CPU utilization is averaging 90% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  }
}


#bcs
resource "aws_cloudwatch_metric_alarm" "bcs_cpu_severe" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe__BCS__${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = "CPU utilization is averaging 90% for ${data.terraform_remote_state.ec2-ndl-bcs.bcs_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  }
}


#bfs
resource "aws_cloudwatch_metric_alarm" "bfs_cpu_severe" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe__BFS__${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = "CPU utilization is averaging 90% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  }
}


### CPU Alarms critical Level

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_cpu_critical" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__critical__BWS__${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "92"
  alarm_description         = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bws.bws_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  }
}


#dis
resource "aws_cloudwatch_metric_alarm" "dis_cpu_critical" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__critical__DIS__${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "92"
  alarm_description         = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-dis.dis_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  }
}


#bps
resource "aws_cloudwatch_metric_alarm" "bps_cpu_critical" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__critical__BPS__${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "92"
  alarm_description         = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  }
}


#bcs
resource "aws_cloudwatch_metric_alarm" "bcs_cpu_critical" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__critical__BCS__${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "92"
  alarm_description         = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bcs.bcs_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  }
}


#bfs
resource "aws_cloudwatch_metric_alarm" "bfs_cpu_critical" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__critical__BFS__${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "92"
  alarm_description         = "CPU utilization is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS Team or AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  }
}
