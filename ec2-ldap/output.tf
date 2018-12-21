# primary ec2
output "primary_instance_id" {
  value = "${module.ldap-primary.instance_id}"
}

output "primary_instance_private_ip" {
  value = "${module.ldap-primary.private_ip}"
}

# dns
output "primary-instance-dns" {
  value = "${aws_route53_record.ldap-primary.fqdn}"
}

# replica ec2
output "replica_instance_id" {
  value = "${module.ldap-replica.instance_id}"
}

output "replica_instance_private_ip" {
  value = "${module.ldap-replica.private_ip}"
}

# dns
output "replica-instance-dns" {
  value = "${aws_route53_record.ldap-replica.fqdn}"
}
