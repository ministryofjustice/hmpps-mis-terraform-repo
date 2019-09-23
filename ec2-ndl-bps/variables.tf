variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {}

variable "bps_instance_type" {}
variable "bps_root_size" {}
variable "bps_server_count" {
  description = "Number of BPS Servers to deploy"
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
  default = "CreateSnapshotBPS"
}
