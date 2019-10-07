### Alarms

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids)}"
  alarm_name                = "BWS-instance-cpu-alarm-${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  }
}


#dis
resource "aws_cloudwatch_metric_alarm" "dis_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids)}"
  alarm_name                = "DIS-instance-cpu-alarm-${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  }
}


#bps
resource "aws_cloudwatch_metric_alarm" "bps_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids)}"
  alarm_name                = "BPS-instance-cpu-alarm-${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  }
}


#bcs
resource "aws_cloudwatch_metric_alarm" "bcs_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids)}"
  alarm_name                = "BCS-instance-cpu-alarm-${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  }
}


#bfs
resource "aws_cloudwatch_metric_alarm" "bfs_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids)}"
  alarm_name                = "BFS-instance-cpu-alarm-${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  }
}
