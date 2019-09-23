variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {}

variable "bcs_instance_type" {}

variable "bcs_root_size" {}

variable "bcs_server_count" {
  description = "Number of BCS Servers to deploy"
  default = 1
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

variable "snap_tag" {
  default = "CreateSnapshotBCS"
}
