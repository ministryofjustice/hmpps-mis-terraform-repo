variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

###
variable "region" {
  description = "The AWS region."
}

variable "environment_type" {
  description = "environment"
}

variable "project_name" {
  description = "The project name - delius-core"
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "tags" {
  type = map(string)
}

variable "ansible_vars_misboe_db" {
  description = "Ansible (oracle_db) vars for user_data script "
  type        = map(string)
}

variable "db_size_misboe" {
  description = "Details of the database resources size"
  type        = map(string)
}

variable "dependencies_bucket_arn" {
  description = "arn for Delius Depencies S3 bucket in the Engineering AWS Account"
}

variable "environment_name" {
  type = string
}

variable "database_high_availability_count" {
  description = "number of standby databases"
  type        = map(number)
}
