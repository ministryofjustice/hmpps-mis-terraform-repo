#BWS LB
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


resource "aws_cloudwatch_metric_alarm" "bws_lb_latency" {
  alarm_name                = "${local.bws_lb_name}-lb-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "Latency"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors BWS lb Latency"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"

  dimensions {
              LoadBalancerName  = "${local.bws_lb_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "bws_lb_spillovercount" {
  alarm_name                = "${local.bws_lb_name}_lb-spill_over_count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "SpilloverCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors BWS lb Latency"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"

  dimensions {
              LoadBalancerName  = "${local.bws_lb_name}"
  }
}


resource "aws_cloudwatch_metric_alarm" "ses_auth_fail" {
  alarm_name                = "Ses_Auth_Fail_Alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "${aws_cloudwatch_log_metric_filter.SesAuthenticationFail.name}"
  namespace                 = "AWS/LogMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors BWS lb Latency"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"
}


resource "aws_cloudwatch_log_metric_filter" "SesAuthenticationFail" {
  name           = "SesAuthenticationFail"
  pattern        = "535 Authentication Credentials Invalid"
  log_group_name = "${var.short_environment_identifier}/smtp_logs"

  metric_transformation {
    name      = "EventCount"
    namespace = "smtp"
    value     = "1"
  }
}


#Nextcloud LB

resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_unhealthy_hosts" {
  alarm_name                = "${local.nextcloud_lb_name}-lb-unhealthy-hosts-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors Nextcloud lb unhealthy host count"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
              LoadBalancerName  = "${local.nextcloud_lb_name}"
  }
}


resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_latency" {
  alarm_name                = "${local.nextcloud_lb_name}-lb-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "Latency"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors Nextcloud lb Latency"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"

  dimensions {
              LoadBalancerName  = "${local.nextcloud_lb_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_spillovercount" {
  alarm_name                = "${local.nextcloud_lb_name}_lb-spill_over_count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "SpilloverCount"
  namespace                 = "AWS/ELB"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors Nextcloud lb Latency"
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  treat_missing_data        = "notBreaching"

  dimensions {
              LoadBalancerName  = "${local.nextcloud_lb_name}"
  }
}
