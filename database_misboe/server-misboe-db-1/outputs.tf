## For ease of maintenance outputs are close to resource creation.

output "kms_arn" {
    value = "${module.kms_key_misboe_db.kms_arn}"
}