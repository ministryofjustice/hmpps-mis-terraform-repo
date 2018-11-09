variable "region" {}

variable "environment_type" {
  description = "environment"
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "size" {
  description = "active directory size"
  default     = "small"
}

variable "ad_password_length" {
  default = "18"
}

variable "instance_type" {
  default = "t2.medium"
}
