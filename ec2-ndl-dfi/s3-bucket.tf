locals {
  bucket_name = "${var.region}-${var.environment_name}-dfi-extracts"
}


data "template_file" "dfi" {
  template = "${file("./templates/s3_policy.tpl")}"

  vars = {
    dfi_account      = var.dfi_account_ids
    region           = var.region
    environment_name = var.environment_name
  }
}

resource "aws_s3_bucket_policy" "dfi" {
  bucket = aws_s3_bucket.dfi.id
  policy = data.template_file.dfi.rendered
}



resource "aws_s3_bucket" "dfi" {
  bucket = local.bucket_name

  acl    = "private"

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

resource "aws_s3_bucket_object" "dfi" {
    for_each = toset(["DFInterventions"])
    bucket   = aws_s3_bucket.dfi.id
    acl      = "private"
    key      = format("%s/", each.key)
}

#resource "aws_s3_bucket_ownership_controls" "dfi" {
#  bucket = aws_s3_bucket.dfi.id
#
#  rule {
#    object_ownership = "BucketOwnerPreferred"
#  }
#}
