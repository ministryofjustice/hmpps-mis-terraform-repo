variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {}

variable "dis_instance_type" {}

variable "dis_root_size" {}

variable "dis_server_count" {
  description = "Number of DIS Servers to deploy"
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
  default = "CreateSnapshotDIS"
}
