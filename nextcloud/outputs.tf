output "public_fqdn_nextcloud_elb" {
  value = "${aws_route53_record.dns_entry.fqdn}"
}

output "fqdn_nextcloud_db" {
  value = "${aws_route53_record.mariadb_dns_entry.fqdn}"
}

output "nextcloud_admin_pass_param" {
  value = "${aws_ssm_parameter.nextcloud_ssm_password.id}"
}

output "nextcloud_db_user_pass_param" {
  value = "${aws_ssm_parameter.nextcloud_db_password.id}"
}

output "nextcloud_efs_share_dns" {
  value = "${module.efs_share.efs_dns_name}"
}
