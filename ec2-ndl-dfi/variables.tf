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

variable "dfi_instance_type" {
}

variable "dfi_root_size" {
}

variable "dfi_server_count" {
  description = "Number of DFI Servers to deploy"
  default     = 0
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
  default = "CreateSnapshotDFI"
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

variable "dfi-listener" {
  description = "A list of listener blocks"
  type        = list(string)
  default     = []
}

variable "access_logs" {
  description = "An access logs block"
  type        = list(string)
  default     = []
}

variable "tags" {
type = map(string)
}

variable "lifecycle_expiration" {
  description = "Specifies a period in the object's expire"
  default     = 30
}

variable "aws_account_ids" {
  description = "Cloud_Platform Account ID with access to DFI bucket"
}

variable "dfi_server_resources" {
  description = "Whether AWS Backup and loadbalancer resources should be created for dfi server"
  default     = 0
}

variable "http_protocol" {
  default = "http"
}

variable "http_port" {
  default = 80
}

variable "dfi_disable_api_termination" {
  type = bool
}

variable "dfi_ebs_optimized" {
  type = bool
}

variable "dfi_hibernation" {
  type = bool
}
