variable "region" {
}

variable "environment_type" {
  description = "environment"
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "nextcloud_backups_config" {
  type = map(string)
  default = {
    transition_days                            = 7
    expiration_days                            = 14
    noncurrent_version_transition_days         = 30
    noncurrent_version_transition_glacier_days = 60
    noncurrent_version_expiration_days         = 2560
  }
}

