output "kms_arn_db_bdb" {
  value = "${module.kms_key_db_bdb.kms_arn}"
}

output "kms_key_id_db_bdb" {
  value = "${module.kms_key_db_bdb.key_id}"
}

output "public_fqdn_ndl_bdb" {
  value = "${module.ndl_bdb.public_fqdn}"
}

output "internal_fqdn_ndl_bdb" {
  value = "${module.ndl_bdb.internal_fqdn}"
}

output "private_ip_ndl_bdb" {
  value = "${module.ndl_bdb.private_ip}"
}
