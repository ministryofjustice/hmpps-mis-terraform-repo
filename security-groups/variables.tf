variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "user_access_cidr_blocks" {
  type = list(string)
}

variable "env_user_access_cidr_blocks" {
  type = list(string)
}

variable "bws_port" {
  default = "8080"
}

