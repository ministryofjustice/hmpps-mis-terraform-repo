variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {}

variable "bws_instance_type" {}


# LB
variable "cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 60
}

variable "connection_draining" {
  description = "Boolean to enable connection draining"
  default     = false
}

variable "connection_draining_timeout" {
  description = "The time in seconds to allow for connections to drain"
  default     = 300
}

variable "bws-listener" {
  description = "A list of listener blocks"
  type        = "list"
  default     = []
}

variable "access_logs" {
  description = "An access logs block"
  type        = "list"
  default     = []
}

variable "bws-health_check" {
  description = "A health check block"
  type        = "list"
  default     = []
}

variable "deploy_node" {}

variable "bws_root_size" {}