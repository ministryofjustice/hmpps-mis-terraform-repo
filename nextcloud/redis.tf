#-------------------------------------------------------------
### Redis elastic cache
#-------------------------------------------------------------

resource "aws_elasticache_subnet_group" "nextcloud" {
  name        = "${local.short_environment_identifier}-nextcloud-cache-subnet"
  description = "${local.short_environment_identifier}-nextcloud-cache-subnet"
  subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
}

resource "aws_elasticache_replication_group" "nextcloud_cache" {
  replication_group_id          = "${local.mis_app_name}-${local.app_name}-rg"
  replication_group_description = "${local.mis_app_name}-${local.app_name} replication group"
  automatic_failover_enabled    = true
  node_type                     = var.nextcloud_redis_node_type
  number_cache_clusters         = var.number_cache_clusters
  subnet_group_name             = aws_elasticache_subnet_group.nextcloud.name
  security_group_ids         = [local.sg_https_out]
  port                       = 6379
  at_rest_encryption_enabled = true
  tags                       = var.tags
}

resource "aws_route53_record" "nextcloud_cache_dns" {
  zone_id = local.private_zone_id
  name    = "${local.app_name}-cache"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.nextcloud_cache.primary_endpoint_address]
}
