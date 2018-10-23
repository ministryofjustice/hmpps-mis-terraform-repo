# Common variables
variable "eng-remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "eng_role_arn" {}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "short resource label or name"
}

variable "region" {
  description = "The AWS region."
}

variable "environment_type" {
  description = "environment"
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "lb_account_id" {}

variable "role_arn" {}

variable "route53_hosted_zone_id" {}

variable "mis_app_name" {}

variable "cloudwatch_log_retention" {}

variable "eng_root_arn" {}
