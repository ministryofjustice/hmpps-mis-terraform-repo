####################################################
# S3 Buckets - Application specific
####################################################

output "s3bucket" {
  value = "${module.s3bucket.s3bucket}"
}
