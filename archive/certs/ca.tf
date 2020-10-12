############################################
# CREATE TLS KEY
############################################
# CA KEY
module "ca_key" {
  ###source    = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/tls/tls_private_key?ref=terraform-0.12"
  source    = "../temp_modules/tls_private_key"
  algorithm = var.self_signed_ca_algorithm
  rsa_bits  = var.self_signed_ca_rsa_bits
}

############################################
# CREATE TLS CA CERT
############################################
# # CA CERT
module "ca_cert" {
  ##source                = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/tls/tls_self_signed_cert?ref=terraform-0.12"
  source                = "../temp_modules/tls_self_signed_cert"
  key_algorithm         = var.self_signed_ca_algorithm
  private_key_pem       = module.ca_key.private_key
  subject               = local.subject
  validity_period_hours = var.self_signed_ca_validity_period_hours
  early_renewal_hours   = var.self_signed_ca_early_renewal_hours
  is_ca_certificate     = var.is_ca_certificate
  allowed_uses          = local.allowed_uses
}

############################################
# ADD TO SSM
############################################
# Add to SSM
module "create_parameter_ca_cert" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ssm/parameter_store_file?ref=terraform-0.12"
  parameter_name = "${local.common_name}-self-signed-ca-crt"
  description    = "${local.common_name}-self-signed-ca-crt"
  type           = "String"
  value          = module.ca_cert.cert_pem
  tags           = local.tags
}

module "create_parameter_ca_key" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ssm/parameter_store_file?ref=terraform-0.12"
  parameter_name = "${local.common_name}-self-signed-ca-key"
  description    = "${local.common_name}-self-signed-ca-key"
  type           = "SecureString"
  value          = module.ca_key.private_key
  tags           = local.tags
}
