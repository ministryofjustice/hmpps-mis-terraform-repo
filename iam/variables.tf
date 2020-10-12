variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "eng_role_arn" {
}

variable "environment_type" {
  description = "environment"
}

variable "cross_account_iam_role" {
}

variable "dependencies_bucket_arn" {
  description = "arn for Delius Depencies S3 bucket in the Engineering AWS Account"
}

variable "migration_bucket_arn" {
  description = "arn for Migration S3 bucket in the Engineering AWS Account"
}

