variable "common_name" {
}

variable "ec2_policy_file" {
}

variable "ec2_internal_policy_file" {
}

variable "tags" {
  type = map(string)
}

variable "s3-config-bucket" {
}

variable "artefact-bucket" {
}

variable "s3_oracledb_backups_arn" {
  description = "Oracle database backups S3 bucket arn"
  default     = ""
}

variable "s3_ssm_ansible_arn" {
  description = "ssm docs s3 bucket arn"
  default     = ""
}

variable "delius-deps-bucket" {
  description = "delius dependencies in Engineering AWS Account name S3 bucket name"
  default     = ""
}

variable "migration-bucket" {
  description = "Migrations in Engineering AWS Account name S3 bucket name"
  default     = ""
}

variable "runtime_role" {
  default = ""
}

variable "region" {
}

variable "account_id" {
}

