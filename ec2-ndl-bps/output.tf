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

####################################################
# instance 2
####################################################

# secondary ec2
output "secondary_instance_id" {
  value = "${module.create-ec2-instance1.instance_id}"
}

output "secondary_private_ip" {
  value = "${module.create-ec2-instance1.private_ip}"
}

# secondary ebs
output "secondary_ebs_id" {
  value = "${module.ebs-ec2-instance1.id}"
}

output "secondary_ebs_arn" {
  value = "${module.ebs-ec2-instance1.arn}"
}

# dns
output "secondary_dns" {
  value = "${aws_route53_record.instance1.fqdn}"
}

####################################################
# instance 3
####################################################

# third ec2
output "third_instance_id" {
  value = "${module.create-ec2-instance2.instance_id}"
}

output "third_private_ip" {
  value = "${module.create-ec2-instance2.private_ip}"
}

# third ebs
output "third_ebs_id" {
  value = "${module.ebs-ec2-instance2.id}"
}

output "third_ebs_arn" {
  value = "${module.ebs-ec2-instance2.arn}"
}

# dns
output "third_dns" {
  value = "${aws_route53_record.instance2.fqdn}"
}
