####################################################
# S3 Buckets - Application specific
####################################################

output "s3bucket" {
  value = "${module.s3bucket.s3bucket}"
}

output "nextcloud_s3_bucket" {
  value = "${aws_s3_bucket.backups.bucket}"
}
