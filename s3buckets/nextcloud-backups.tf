#-------------------------------------------
### S3 bucket for backups
#--------------------------------------------

locals {
  transition_days = var.nextcloud_backups_config["transition_days"]
  expiration_days = var.nextcloud_backups_config["expiration_days"]
  bucket_name     = "${data.terraform_remote_state.common.outputs.environment_identifier}-nextcloud-backups"
}

resource "aws_s3_bucket" "backups" {
  bucket = local.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expiration_days
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = local.bucket_name
    },
  )
}

#-------------------------------------------
### S3 bucket for migration to datasync
#--------------------------------------------

resource "aws_s3_bucket" "migration_datasync" {
  bucket = "nextcloud-migration"
  acl    = "private"

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "migration_datasync" {
  bucket = aws_s3_bucket.migration_datasync.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resources = [
          "${aws_s3_bucket.migration_datasync.arn}",
          "${aws_s3_bucket.migration_datasync.arn}/*",
        ],
      },
    ],
  })
}
