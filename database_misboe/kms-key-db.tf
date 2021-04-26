module "kms_key_misboe_db" {
  source   = "../modules/keys/encryption_key"
  key_name = "${var.environment_type}-misboe-db"
  tags = merge(
    local.tags,
    {
      "Name" = "${var.environment_type}-misboe-db"
    },
  )
  environment_name = var.environment_name
}
