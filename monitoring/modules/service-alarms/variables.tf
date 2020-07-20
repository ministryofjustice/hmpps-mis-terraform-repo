variable "service_name" {
  description = "Name of service"
}

variable "alarm_name" {
  description = "Name of alarm must be in this format EnvName__ServiceName__Severity"
}

variable "metric_name" {
  description = "Service name without dots or dashes"
}

variable "name_space" {
  description = "The cloudwatch namespace"
}

variable "host" {
  description = "Host where the service is running"
}

variable "mis_team_action" {
  description = "Action to take when an alarm is raised"
}

variable "alarm_actions" {
   description = "SNS topic arn to send notifications"
}

variable "pattern" {
  description = "Pattern matched in logs. Must include Error or Critical log levels only ie local.exclude_log_level PROCTIER001.WebIntelligenceProcessingServer1"
}

variable "log_group_name" {
  description = "The log group name"
}

variable "pattern_ok" {
  description = "Patten for OK Alerts. Must include INFO log level only"
}
