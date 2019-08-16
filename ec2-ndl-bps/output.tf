output "bps_instance_ids" {
  value = "${aws_instance.bps_server.*.id}"
}

output "bps_private_ips" {
  value = "${aws_instance.bps_server.*.private_ip}"
}

# dns
output "bps_primary_dns" {
  value = "${aws_route53_record.bps_dns.*.fqdn}"
}

output "bps_primary_dns_ext" {
  value = "${aws_route53_record.bps_dns.*.fqdn}"
}