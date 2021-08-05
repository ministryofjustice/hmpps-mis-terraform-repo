variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {
}

variable "bps_instance_type" {
}

variable "bps_root_size" {
}

variable "bps_server_count" {
  description = "Number of BPS Servers to deploy"
  default     = 1
}

variable "ebs_backup" {
  type = map(string)

  default = {
    schedule     = "cron(0 01 * * ? *)"
    delete_after = 15
  }
}

variable "environment_name" {
  type = string
}

variable "snap_tag" {
  default = "CreateSnapshotBPS"
}

variable "bps_disable_api_termination" {
  type = bool
}

variable "bps_ebs_optimized" {
  type = bool
}

variable "bps_hibernation" {
  type = bool
}

variable "mis_overide_autostop_tags" {
  default = "False"
}
