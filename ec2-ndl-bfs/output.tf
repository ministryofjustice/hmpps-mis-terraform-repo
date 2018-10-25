# primary ec2
output "primary_instance_id" {
  value = "${module.create-ec2-instance.instance_id}"
}

output "primary_private_ip" {
  value = "${module.create-ec2-instance.private_ip}"
}

# primary ebs
output "primary_ebs_id" {
  value = "${module.ebs-ec2-instance.id}"
}

output "primary_ebs_arn" {
  value = "${module.ebs-ec2-instance.arn}"
}

# dns
output "primary_dns" {
  value = "${aws_route53_record.instance.fqdn}"
}
