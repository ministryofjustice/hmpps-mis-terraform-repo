# primary ec2
output "primary_instance_id" {
  value = "${module.create-ec2-instance.instance_id}"
}

output "primary_private_ip" {
  value = "${module.create-ec2-instance.private_ip}"
}

# dns
output "primary_dns" {
  value = "${aws_route53_record.instance.fqdn}"
}

output "primary_dns_ext" {
  value = "${aws_route53_record.instance_ext.fqdn}"
}

# secondary ec2
output "secondary_instance_id" {
  value = "${module.create-ec2-instance-002.instance_id}"
}

output "secondary_private_ip" {
  value = "${module.create-ec2-instance-002.private_ip}"
}

# dns
output "secondary_dns" {
  value = "${aws_route53_record.instance_002.*.fqdn}"
}

output "secondary_dns_ext" {
  value = "${aws_route53_record.instance_ext_002.*.fqdn}"
}