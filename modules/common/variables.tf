variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "short resource label or name"
}

variable "region" {
  description = "The AWS region."
}

variable "environment" {
  description = "environment"
}

variable "s3_lb_policy_file" {}

variable "lb_account_id" {}

variable "private_zone_id" {}

variable "spg_app_name" {}

variable "vpc_id" {}
variable "cidr_block" {}
variable "internal_domain" {}

variable "tags" {
  type = "map"
}

variable "common_name" {}
