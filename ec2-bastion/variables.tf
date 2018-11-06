variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "cloudwatch_log_retention" {}

variable "instance_type" {
  default = "t2.micro"
}
