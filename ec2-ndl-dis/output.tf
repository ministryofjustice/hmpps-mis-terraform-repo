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

#dis ami_id
output "dis_ami_id" {
  value = "${aws_instance.dis_server.*.ami}"
}

#dis instance_type
output "dis_instance_type" {
  value = "${aws_instance.dis_server.*.instance_type}"
}
