variable "region" {
  type = string
}

variable "remote_state_bucket_name" {
  type = string
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  type = string
  description = "environment"
}

variable "environment_name" {
  type = string
}

variable "mis_app_name" {
  type = string
  default = "mis"
}