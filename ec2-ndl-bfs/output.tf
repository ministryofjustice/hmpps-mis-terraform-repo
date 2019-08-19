# primary ec2
output "bfs_instance_ids" {
  value = "${aws_instance.bfs_server.*.id}"
}

output "bfs_private_ips" {
  value = "${aws_instance.bfs_server.*.private_ip}"
}

# dns
output "bfs_primary_dns" {
  value = "${aws_route53_record.bfs_dns.*.fqdn}"
}

output "bfs_primary_dns_ext" {
  value = "${aws_route53_record.bfs_dns.*.fqdn}"
}
