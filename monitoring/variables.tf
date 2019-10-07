variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "alarms_enabled" {
  type = "string"
}

variable "short_environment_identifier" {}
