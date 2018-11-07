output "kms_arn_db" {
  value = "${module.kms_key_db.kms_arn}"
}

output "kms_key_id_db" {
  value = "${module.kms_key_db.key_id}"
}

output "public_fqdn_ndl_ddb" {
  value = "${module.ndl_ddb.public_fqdn}"
}

output "internal_fqdn_ndl_ddb" {
  value = "${module.ndl_ddb.internal_fqdn}"
}

output "private_ip_ndl_ddb" {
  value = "${module.ndl_ddb.private_ip}"
}
