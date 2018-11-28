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
