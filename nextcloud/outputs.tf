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


output "nextcloud_lb_name" {
  value = "${module.nextcloud_lb.environment_elb_name}"
}

output "samba_lb_name" {
  value = "${aws_elb.samba_lb.name}"
}
