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
  value       = element(concat(aws_elb.dfi.*.id, [""]), 0)
}

output "dfi_elb_name" {
  description = "The name of the ELB"
  value       = element(concat(aws_elb.dfi.*.name, [""]), 0)
}

output "dfi_elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = element(concat(aws_elb.dfi.*.dns_name, [""]), 0)
}

output "dfi_elb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = element(concat(aws_elb.dfi.*.zone_id, [""]), 0)
}

output "dfi_elb_dns_cname" {
  value = element(concat(aws_route53_record.dns_entry.*.fqdn, [""]), 0)
}

#Log group
output "datasync_log_group_name" {
  value = aws_cloudwatch_log_group.s3_to_efs.name
}

#dfi s3bucket
output "dfi_s3bucket_name" {
  value = aws_s3_bucket.dfi.id
}
