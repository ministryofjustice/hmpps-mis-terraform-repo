locals {
  bucket_name = "${var.region}-${var.environment_name}-dfi-extracts"
}

data "aws_ssm_parameter" "cross_account_sync_id" {
  name = "dfi-cross-account-sync-development"
}

data "aws_ssm_parameter" "sync_user" {
  name = "github-dfi-cross-account-sync-user"
}


data "template_file" "dfi" {
  template = file("./templates/s3_policy.tpl")

  vars = {
    dfi_account      = var.aws_account_ids["cloud-platform"]
    region           = var.region
    environment_name = var.environment_name
    account_id       = data.aws_ssm_parameter.cross_account_sync_id.value
    sync_user        = data.aws_ssm_parameter.sync_user.value
  }
}

resource "aws_s3_bucket_policy" "dfi" {
  bucket = aws_s3_bucket.dfi.id
  policy = data.template_file.dfi.rendered
}



resource "aws_s3_bucket" "dfi" {
  bucket = local.bucket_name

  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
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
    expiration {
      days = var.lifecycle_expiration
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = local.bucket_name
    },
  )
}

#Create folders for dfi
resource "aws_s3_bucket_object" "dfi" {
  for_each = toset(["dfi"])
  bucket   = aws_s3_bucket.dfi.id
  acl      = "private"
  key      = format("/dfinterventions/%s/", each.key)
}

#Create folder for infected files
resource "aws_s3_bucket_object" "infected" {
  bucket = aws_s3_bucket.dfi.id
  acl    = "private"
  key    = "/infected/"
}

#resource "aws_s3_bucket_ownership_controls" "dfi" {
#  bucket = aws_s3_bucket.dfi.id
#
#  rule {
#    object_ownership = "BucketOwnerPreferred"
#  }
#}
