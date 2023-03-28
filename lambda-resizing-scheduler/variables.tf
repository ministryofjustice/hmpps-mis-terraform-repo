variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_name" {
  description = "Environment name to be used as a unique identifier for resources - eg. delius-core-dev"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "resizing_schedule_am_expression" {
  description = "Schedule to run ETL resizing schedule in the morning after ETL jobs run times"
  default = "cron(05 05 * * ? *)"
}

variable "resizing_schedule_pm_expression" {
  description = "Schedule to run ETL resizing schedule in the evening before ETL jobs run times"
  default = "cron(00 17 * * ? *)"
}

variable "mis_overide_resizing_schedule_tags" {
  description = "Tag attached to DIS instances for MIS. Tag defines whether server resizing is enabled/disabled at the scheduled times. This value is set in hmpps-env-configs repo"
}

variable "dis_instance_type" {
  description = "DIS instance type. This value is set in hmpps-env-configs repo"
}

variable "dis_instance_type_lower" {
  description = "DIS instance type required when not running ETL jobs. This is a lower value than dis_instance_type. This value is set in hmpps-env-configs repo"
}

variable "cloudwatch_log_retention" {
  description =  "Number of days to retain cloudwatch logs"
  default = "14"
}

variable "mis_alarms_enabled" {
  type = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}