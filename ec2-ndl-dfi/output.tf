output "dfi_instance_ids" {
  value = aws_instance.dfi_server.*.id
}

output "dfi_private_ips" {
  value = aws_instance.dfi_server.*.private_ip
}

# dns
output "dfi_primary_dns" {
  value = aws_route53_record.dfi_dns.*.fqdn
}

output "dfi_primary_dns_ext" {
  value = aws_route53_record.dfi_dns_ext.*.fqdn
}

#dfi ami_id
output "dfi_ami_id" {
  value = aws_instance.dfi_server.*.ami
}

#dfi instance_type
output "dfi_instance_type" {
  value = aws_instance.dfi_server.*.instance_type
}

# ELB
output "dfi_elb_id" {
  description = "The name of the ELB"
  value       = module.create_app_elb.environment_elb_id
}

output "dfi_elb_name" {
  description = "The name of the ELB"
  value       = module.create_app_elb.environment_elb_name
}

output "dfi_elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = module.create_app_elb.environment_elb_dns_name
}

output "dfi_elb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = module.create_app_elb.environment_elb_zone_id
}

output "dfi_elb_dns_cname" {
  value = aws_route53_record.dns_entry.fqdn
}
