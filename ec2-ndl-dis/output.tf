output "dis_instance_ids" {
  value = "${aws_instance.dis_server.*.id}"
}

output "dis_private_ips" {
  value = "${aws_instance.dis_server.*.private_ip}"
}

# dns
output "dis_primary_dns" {
  value = "${aws_route53_record.dis_dns.*.fqdn}"
}

output "dis_primary_dns_ext" {
  value = "${aws_route53_record.dis_dns.*.fqdn}"
}
