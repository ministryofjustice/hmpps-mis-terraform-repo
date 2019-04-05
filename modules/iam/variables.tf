variable "common_name" {}

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

variable "backups-bucket" {
  description = "database backups s3 bucket name"
  default = ""
}

variable "delius-deps-bucket" {
  description = "delius dependencies in Engineering AWS Account name S3 bucket name"
  default = ""
}

variable "migration-bucket" {
  description = "Migrations in Engineering AWS Account name S3 bucket name"
  default = ""
}

variable "runtime_role" {
  default = ""
}

variable "region" {}

variable "account_id" {}
