variable "region" {}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_type" {
  description = "environment"
}

variable "nextcloud_instance_type" {}

variable "bastion_inventory" {}

variable "instance_count" {
  default = "1"
}

variable "tags" {
  type     = "map"
}
