#--------------------------------------------------------
#BWS LB Alerts
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bws_lb_unhealthy_hosts_alert" {
  alarm_name          = "${var.environment_type}__UnHealthyHostCount__alert__BWS__${local.bws_lb_name}-lb"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "The BWS loadbalancer ${local.bws_lb_name} has 1 Unhealthy host. Please contact the MIS Team or the MIS AWS Support contact"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    LoadBalancer     = local.bws_elb_arn_suffix
    TargetGroup      = local.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "bws_lb_unhealthy_hosts_critical" {
  alarm_name          = "${var.environment_type}__UnHealthyHostCount__critical__BWS__${local.bws_lb_name}-lb"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "The BWS loadbalancer ${local.bws_lb_name} has 2 Unhealthy hosts. Please contact the MIS Team or the MIS AWS Support contact"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    LoadBalancer     = local.bws_elb_arn_suffix
    TargetGroup      = local.target_group_arn_suffix
  }
}

#--------------------------------------------------------
#LB Mgmt Pipeline Failure Alert
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "lb_mgmt_alert" {
  alarm_name          = "${var.environment_type}__lb_mgmt_pipeline_errors__alert"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "LbMgmtPipelineErrorCount"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "CodeBuild ${var.environment_name}-${local.mis_app_name}-lb-rule-mgmt-build completed with errors. Please review log group ${local.bws_lb_mgmt_pipeline_log_group_name}"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  datapoints_to_alarm = "1"
  treat_missing_data  = "notBreaching"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "lb_mgmt_alert" {
  name           = "LbMgmtPipelineErrorCount"
  pattern        = local.bws_pipeline_failure_pattern
  log_group_name = local.bws_lb_mgmt_pipeline_log_group_name

  metric_transformation {
    name      = "LbMgmtPipelineErrorCount"
    namespace = local.name_space
    value     = "1"
  }
  depends_on = [aws_cloudwatch_log_group.lb_mgmt]
}

#--------------------------------------------------------
#Nextcloud LB Alerts
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_unhealthy_hosts_alert" {
  alarm_name          = "${var.environment_type}__UnHealthyHostCount__alert__NEXTCLOUD__${local.nextcloud_lb_name}-lb"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "The NEXTCLOUD loadbalancer ${local.nextcloud_lb_name} has 1 Unhealthy host. Please contact the MIS AWS Support contact"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    LoadBalancerName = local.nextcloud_lb_name
  }
}

resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_unhealthy_hosts_critical" {
  alarm_name          = "${var.environment_type}__UnHealthyHostCount__critical__NEXTCLOUD__${local.nextcloud_lb_name}-lb"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "The NEXTCLOUD loadbalancer ${local.nextcloud_lb_name} has 2 Unhealthy hosts. Please contact the MIS AWS Support contact"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    LoadBalancerName = local.nextcloud_lb_name
  }
}

resource "aws_cloudwatch_metric_alarm" "nextcloud_lb_spillovercount" {
  alarm_name          = "${var.environment_type}__SpilloverCount__severe__NEXTCLOUD__${local.nextcloud_lb_name}-lb"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "SpilloverCount"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "The NEXTCLOUD loadbalancer ${local.nextcloud_lb_name} is averaging a spillover count of 1. Please contact the MIS AWS Support contact."
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  treat_missing_data  = "notBreaching"
  tags                = local.tags

  dimensions = {
    LoadBalancerName = local.nextcloud_lb_name
  }
}

#--------------------------------------------------------
#Samba LB Alerts
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "samba_lb_unhealthy_hosts_alert" {
  alarm_name          = "${var.environment_type}__UnHealthyHostCount__alert__SAMBA__${local.samba_lb_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "The NEXTCLOUD Samba loadbalancer ${local.samba_lb_name} has 1 Unhealthy host. BO - Nextcloud Syncs may be degraded. Please contact the MIS AWS Support contact"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    LoadBalancerName = local.samba_lb_name
  }
}

resource "aws_cloudwatch_metric_alarm" "samba_lb_unhealthy_hosts_critical" {
  alarm_name          = "${var.environment_type}__UnHealthyHostCount__critical__SAMBA__${local.samba_lb_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "The NEXTCLOUD Samba loadbalancer ${local.samba_lb_name} has 2 Unhealthy hosts. BO - Nextcloud Syncs not functioning!. Please contact the MIS AWS Support contact"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  tags                = local.tags

  dimensions = {
    LoadBalancerName = local.samba_lb_name
  }
}


#--------------------------------------------------------
#SMTP LB Alerts
#--------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ses_auth_fail" {
  alarm_name          = "${var.environment_type}__SesAuthenticationFail__critical__SMTP"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "SesAuthenticationFail"
  namespace           = local.name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "The SMTP Server has failed to authenticate to AWS SES. Emails will not be delivered!. Please contact the AWS Support Team"
  alarm_actions       = [aws_sns_topic.alarm_notification.arn]
  ok_actions          = [aws_sns_topic.alarm_notification.arn]
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = "1"
  tags                = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "SesAuthenticationFail" {
  name           = "SesAuthenticationFail"
  pattern        = "535 Authentication Credentials Invalid"
  log_group_name = "${var.short_environment_identifier}/smtp_logs"

  metric_transformation {
    name      = "SesAuthenticationFail"
    namespace = local.name_space
    value     = "1"
  }
}
