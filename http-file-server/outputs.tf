output "efs_share_dns" {
  value = "${module.efs_share.efs_dns_name}"
}


output "private_fqdn_samba_elb" {
  value = "${aws_route53_record.samba_lb_private.fqdn}"
}

output "public_fqdn_http_fs_elb" {
  value = "${aws_route53_record.dns_entry.fqdn}"
}
