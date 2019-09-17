#-------------------------------------------------------------
### Redis elastic cache
#-------------------------------------------------------------

resource "aws_elasticache_subnet_group" "nextcloud" {
  name        = "${local.short_environment_identifier}-nextcloud-cache-subnet"
  description = "${local.short_environment_identifier}-nextcloud-cache-subnet"
  subnet_ids  = ["${data.terraform_remote_state.vpc.vpc_private-subnet-az1}"]
}

resource "aws_elasticache_cluster" "nextcloud_cache" {
  cluster_id           = "${local.mis_app_name}-${local.app_name}"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.4"
  port                 = 6379
  maintenance_window   = "sun:03:00-sun:06:00"
  security_group_ids   = ["${local.sg_https_out}",]
  apply_immediately    = "false"
  snapshot_window      = "00:00-03:00"
  tags                 = "${var.tags}"
  subnet_group_name    = "${aws_elasticache_subnet_group.nextcloud.id}"
}
