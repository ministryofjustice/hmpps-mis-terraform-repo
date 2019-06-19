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

# ELB
output "bws_elb_id" {
  description = "The name of the ELB"
  value       = "${module.create_app_elb.environment_elb_id}"
}

output "bws_elb_name" {
  description = "The name of the ELB"
  value       = "${module.create_app_elb.environment_elb_name}"
}

output "bws_elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = "${module.create_app_elb.environment_elb_dns_name}"
}

output "bws_elb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = "${module.create_app_elb.environment_elb_zone_id}"
}

output "bws_elb_dns_cname" {
  value = "${aws_route53_record.dns_entry.fqdn}"
}
