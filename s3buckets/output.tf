####################################################
# S3 Buckets - Application specific
####################################################

output "s3bucket" {
  value = "${module.s3bucket.s3bucket}"
}

output "s3bucket-backups" {
  value = "${module.s3bucket-backups.s3_bucket_name}"
}

output "s3_bucket_backups_arn" {
  value = "${module.s3bucket-backups.s3_bucket_arn}"
}
