#-------------------------------------------------------------
### Redis elastic cache
#-------------------------------------------------------------

resource "aws_elasticache_subnet_group" "nextcloud" {
  name        = "${local.short_environment_identifier}-nextcloud-cache-subnet"
  description = "${local.short_environment_identifier}-nextcloud-cache-subnet"
  subnet_ids = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"]
}

resource "aws_elasticache_replication_group" "nextcloud_cache" {
  replication_group_id          = "${local.mis_app_name}-${local.app_name}-rg"
  replication_group_description = "${local.mis_app_name}-${local.app_name} - replication group"
  node_type                     = "${var.nextcloud_redis_node_type}"
  port                          = 6379
  security_group_ids            = ["${local.sg_https_out}",]
  subnet_group_name             = "${aws_elasticache_subnet_group.nextcloud.name}"
  engine                        = "redis"
  engine_version                = "5.0.6"
  automatic_failover_enabled    = true
  at_rest_encryption_enabled    = true
  apply_immediately             = true
  tags                          = "${var.tags}"
  cluster_mode {
    num_node_groups         = "${var.nextcloud_num_node_groups}"
    replicas_per_node_group = "${var.nextcloud_replicas_per_node_group}"
  }
}

resource "aws_route53_record" "nextcloud_cache_dns" {
  zone_id = "${local.private_zone_id}"
  name    = "${local.app_name}-cache"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_elasticache_replication_group.nextcloud_cache.configuration_endpoint_address}"]
}
