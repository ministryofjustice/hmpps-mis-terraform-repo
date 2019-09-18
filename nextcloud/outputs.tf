output "public_fqdn_nextcloud_elb" {
  value = "${aws_route53_record.dns_entry.fqdn}"
}

output "fqdn_nextcloud_db" {
  value = "${aws_route53_record.mariadb_dns_entry.fqdn}"
}

output "nextcloud_efs_share_dns" {
  value = "${module.efs_share.efs_dns_name}"
}


output "private_fqdn_samba_elb" {
  value = "${aws_route53_record.samba_lb_private.fqdn}"
}
