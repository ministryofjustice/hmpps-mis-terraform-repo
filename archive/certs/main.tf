terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/common/terraform.tfstate"
    region = var.region
  }
}

####################################################
# Locals
####################################################

locals {
  internal_domain        = data.terraform_remote_state.common.outputs.internal_domain
  common_name            = "${data.terraform_remote_state.common.outputs.common_name}-ldap"
  tags                   = data.terraform_remote_state.common.outputs.common_tags
  region                 = var.region
  environment_identifier = data.terraform_remote_state.common.outputs.environment_identifier
  environment            = data.terraform_remote_state.common.outputs.environment

  subject = {
    common_name  = "ca.${local.internal_domain}"
    organization = local.common_name
  }

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]

  server_allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]

  server_dns_names = ["*.${data.terraform_remote_state.common.outputs.internal_domain}"]

  server_subject = {
    common_name  = data.terraform_remote_state.common.outputs.internal_domain
    organization = "${data.terraform_remote_state.common.outputs.common_name}-ldap"
  }
}

