variable "environment_identifier" {}
variable "region" {}

variable "app_name" {}

variable "vpc_id" {}

variable "allowed_cidr_block" {
  type = "list"
}

variable "bastion_cidr" {
  type = "list"
}

variable "tags" {
  type = "map"
}

variable "common_name" {}

variable "public_cidr_block" {
  type = "list"
}

variable "private_cidr_block" {
  type = "list"
}

variable "db_cidr_block" {
  type = "list"
}

variable depends_on {
  default = []
  type    = "list"
}

# SG ids
variable "sg_map_ids" {
  type = "map"
}
