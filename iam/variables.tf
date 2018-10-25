variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "eng_role_arn" {}

variable "environment_type" {
  description = "environment"
}

variable "eng-remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "cross_account_iam_role" {}
