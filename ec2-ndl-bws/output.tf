#-------------------------------------------
# BWS Instances
#-------------------------------------------
output "bws_instance_ids" {
  value = aws_instance.bws_server.*.id
}

output "bws_private_ips" {
  value = aws_instance.bws_server.*.private_ip
}

#bws ami_id
output "bws_ami_id" {
  value = aws_instance.bws_server.*.ami
}

#bws instance_type
output "bws_instance_type" {
  value = aws_instance.bws_server.*.instance_type
}

# dns
output "bws_primary_dns" {
  value = aws_route53_record.bws_dns.*.fqdn
}

output "bws_primary_dns_ext" {
  value = aws_route53_record.bws_dns.*.fqdn
}

#-------------------------------------------
# Application LoadBalancer
#-------------------------------------------
output "bws_elb_id" {
  description = "The name of the Application LoadBalancer"
  value       = aws_lb.alb.id
}

output "bws_elb_name" {
  description = "The name of the Application LoadBalancer"
  value       = aws_lb.alb.name
}

output "bws_elb_dns_name" {
  description = "The DNS name of the Application LoadBalancer"
  value       = aws_lb.alb.dns_name
}

output "bws_elb_zone_id" {
  description = "The canonical hosted zone ID of the Application LoadBalancer (to be used in a Route 53 Alias record)"
  value       = aws_lb.alb.zone_id
}

output "bws_elb_arn_suffix" {
  description = "BWS LB ARN Suffix"
  value       = aws_lb.alb.arn_suffix
}

output "target_group_arn_suffix" {
  description = "BWS Target group ARN Suffix"
  value       = aws_lb_target_group.bws.arn_suffix
}

output "target_group_arn" {
  description = "BWS Target group ARN"
  value       = aws_lb_target_group.bws.arn
}
