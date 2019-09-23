variable "region" {}

variable "environment_type" {
  description = "environment"
}

variable "ebs_backup" {
  type = "map"

  default = {
    schedule           = "cron(0 01 * * ? *)"
    cold_storage_after = 14
    delete_after       = 120
  }
}

variable "environment_name" {
  type = "string"
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}
