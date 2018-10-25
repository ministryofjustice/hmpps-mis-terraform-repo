variable "environment_identifier" {}

variable "app_name" {}

variable "ec2_policy_file" {}

variable "ec2_internal_policy_file" {}

variable "tags" {
  type = "map"
}

variable "s3-config-bucket" {}

variable depends_on {
  default = []
  type    = "list"
}

variable "artefact-bucket" {}
