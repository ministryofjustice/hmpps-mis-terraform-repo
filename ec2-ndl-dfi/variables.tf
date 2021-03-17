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
  default     = 290
}

variable "dfi_account_ids" {
  description = "Account DFI granted access to DFI bucket"
  default     = "431912413968"  #Temp account id until actual account is provided
}
