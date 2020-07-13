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
    delete_after       = 14
  }
}

variable "environment_name" {
  type = "string"
}

variable "snap_tag" {
  default = "CreateSnapshotDIS"
}




# LB
variable "cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 300
}

variable "connection_draining" {
  description = "Boolean to enable connection draining"
  default     = false
}

variable "connection_draining_timeout" {
  description = "The time in seconds to allow for connections to drain"
  default     = 300
}

variable "dis-listener" {
  description = "A list of listener blocks"
  type        = "list"
  default     = []
}

variable "access_logs" {
  description = "An access logs block"
  type        = "list"
  default     = []
}

variable "dis-health_check" {
  description = "A health check block"
  type        = "list"
  default     = []
}
