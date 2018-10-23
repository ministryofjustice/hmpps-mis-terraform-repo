variable "environment_identifier" {}

variable "tags" {
  type = "map"
}

variable depends_on {
  default = []
  type    = "list"
}

variable "passwords" {
  type = "list"
}
