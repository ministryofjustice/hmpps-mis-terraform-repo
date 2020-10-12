output "bws_instance_ids" {
  value = aws_instance.bws_server.*.id
}

output "bws_private_ips" {
  value = aws_instance.bws_server.*.private_ip
}

# dns
output "bws_primary_dns" {
  value = aws_route53_record.bws_dns.*.fqdn
}

output "bws_primary_dns_ext" {
  value = aws_route53_record.bws_dns.*.fqdn
}

# ELB
output "bws_elb_id" {
  description = "The name of the ELB"
  value       = module.create_app_elb.environment_elb_id
}

output "bws_elb_name" {
  description = "The name of the ELB"
  value       = module.create_app_elb.environment_elb_name
}

output "bws_elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = module.create_app_elb.environment_elb_dns_name
}

output "bws_elb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = module.create_app_elb.environment_elb_zone_id
}

output "bws_elb_dns_cname" {
  value = aws_route53_record.dns_entry.fqdn
}

#bws ami_id
output "bws_ami_id" {
  value = aws_instance.bws_server.*.ami
}

#bws instance_type
output "bws_instance_type" {
  value = aws_instance.bws_server.*.instance_type
}

