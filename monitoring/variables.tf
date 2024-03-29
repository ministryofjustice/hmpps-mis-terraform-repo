variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "mis_alarms_enabled" {
  type = string
}

variable "dis_instance_type" {
  description = "DIS instance type"
}

variable "dis_instance_type_lower" {
  description = "Second DIS instance type considered when applying the ETL resizing scheduler"
  default = ""
}

variable "cloudwatch_log_retention" {
}

variable "environment_name" {
  description = "Environment name to be used as a unique identifier for resources - eg. delius-core-dev"
}

variable "short_environment_name" {
  description = "Shortened environment name to be used as a unique identifier for resources with a limit on resource name length - eg. dlc-dev"
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

variable "project_name" {
  description = "Project name to be used when looking up SSM parameters - eg. delius-core"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}