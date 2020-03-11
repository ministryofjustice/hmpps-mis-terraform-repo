module "kms_key_mis_db" {
  source   = "../../modules/keys/encryption_key"
  key_name = "${var.environment_type}-mis-db"
  tags     = "${merge(var.tags, map("Name", "${var.environment_type}-mis-db"))}"
}
