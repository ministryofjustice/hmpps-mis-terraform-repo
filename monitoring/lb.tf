resource "aws_cloudwatch_metric_alarm" "bws_lb_unhealthy_hosts" {
  alarm_name                = "${local.bws_lb_name}-lb-unhealthy-hosts-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors BWS lb unhealthy host count"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
              LoadBalancerName  = "${local.bws_lb_name}"
  }
}



resource "aws_cloudwatch_metric_alarm" "bws_lb_healthy_hosts" {
  alarm_name                = "${local.bws_lb_name}-lb-healthy-hosts-count"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "2"
  alarm_description         = "This metric monitors BWS lb unhealthy host count"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
              LoadBalancerName  = "${local.bws_lb_name}"
  }
}
