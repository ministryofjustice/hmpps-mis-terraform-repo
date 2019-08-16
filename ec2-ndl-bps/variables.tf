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
