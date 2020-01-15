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


# ELB
output "dis_elb_id" {
  description = "The name of the ELB"
  value       = "${module.create_app_elb.environment_elb_id}"
}

output "dis_elb_name" {
  description = "The name of the ELB"
  value       = "${module.create_app_elb.environment_elb_name}"
}

output "dis_elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = "${module.create_app_elb.environment_elb_dns_name}"
}

output "dis_elb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = "${module.create_app_elb.environment_elb_zone_id}"
}

output "dis_elb_dns_cname" {
  value = "${aws_route53_record.dns_entry.fqdn}"
}
