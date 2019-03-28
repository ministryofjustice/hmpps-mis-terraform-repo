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

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "tags" {
  type = "map"
}

variable "ansible_vars_misdsd_db" {
  description = "Ansible (oracle_db) vars for user_data script "
  type        = "map"
}

variable "db_size_misdsd" {
  description = "Details of the database resources size"
  type = "map"
}
