### Alarms

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "CPU utilization is very high for ${data.terraform_remote_state.ec2-ndl-bws.bws_primary_dns_ext[count.index]}"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  }
}


#dis
resource "aws_cloudwatch_metric_alarm" "dis_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "CPU utilization is very high for ${data.terraform_remote_state.ec2-ndl-dis.dis_primary_dns_ext[count.index]}"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  }
}


#bps
resource "aws_cloudwatch_metric_alarm" "bps_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "CPU utilization is very high for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  }
}


#bcs
resource "aws_cloudwatch_metric_alarm" "bcs_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "CPU utilization is very high for ${data.terraform_remote_state.ec2-ndl-bcs.bcs_primary_dns_ext[count.index]}"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  }
}


#bfs
resource "aws_cloudwatch_metric_alarm" "bfs_cpu" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids)}"
  alarm_name                = "${local.environment_name}__CPU-Utilization__severe"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "CPU utilization is very high for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  }
}
