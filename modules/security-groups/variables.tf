variable "environment_identifier" {}
variable "region" {}

variable "spg_app_name" {}

variable "alb_http_port" {}

variable "alb_https_port" {}

variable "alb_backend_port" {}

variable "vpc_id" {}

variable "allowed_cidr_block" {
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
