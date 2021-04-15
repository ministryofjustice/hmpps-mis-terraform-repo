#--------------------------------------------------------
#Datasync Locations
#--------------------------------------------------------
#S3 Location
resource "aws_datasync_location_s3" "dfi" {
  s3_bucket_arn = aws_s3_bucket.dfi.arn
  subdirectory  = "/dfinterventions/dfi"

  s3_config {
    bucket_access_role_arn = aws_iam_role.data_sync_s3_acces.arn
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-dfi-s3-location"
    },
  )
}

#--------------------------------------------------------
#Datasync IAM for s3 access
#--------------------------------------------------------
#IAM Role for access to s3
data "template_file" "data_sync_s3_acces" {
  template = "${file("./templates/data-sync-policy.tpl")}"

  vars = {
    environment_name = var.environment_name
    region           = var.region
  }
}

#IAM Policy for access to s3
resource "aws_iam_policy" "data_sync_s3_acces" {
  name        = "${var.environment_name}-data-sync-s3-access"
  path        = "/"
  description = "${var.environment_name}-data-sync-s3-access"
  policy      = data.template_file.data_sync_s3_acces.rendered
}


#IAM Role for access to s3
resource "aws_iam_role" "data_sync_s3_acces" {
  name = "${var.environment_name}-data-sync-s3-access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "datasync.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-data-sync-s3-access"
    },
  )
}

#Policy attachment for access to s3
resource "aws_iam_role_policy_attachment" "data_sync_s3_acces" {
  role       = aws_iam_role.data_sync_s3_acces.name
  policy_arn = aws_iam_policy.data_sync_s3_acces.arn
}

#--------------------------------------------------------
#Datasync Task
#--------------------------------------------------------
resource "aws_cloudwatch_log_group" "s3_to_efs" {
  name              = "/${var.environment_name}/${local.app_name}/aws/datasync"
  retention_in_days = "30"
  tags = merge(
    var.tags,
    {
      "Name" = "/${var.environment_name}/${local.app_name}/aws/datasync"
    },
  )
}

locals {
  source-location-arn       = aws_datasync_location_s3.dfi.arn
  cloud-watch-log-group-arn = "arn:aws:logs:${var.region}:${local.account_id}:log-group:/${var.environment_name}/${local.app_name}/aws/datasync"
  name                      = "${var.environment_name}-dfi-s3-to-fsx"
  fsx-sg-arn                = "arn:aws:ec2:${var.region}:${local.account_id}:security-group/${local.fsx_integration_security_group}"
  ad_user_param             = "/${var.environment_name}/delius/${local.app_name}-service-accounts/SVC_DFI_NDL/SVC_DFI_NDL_username"
  ad_pass_param             = "/${var.environment_name}/delius/${local.app_name}-service-accounts/SVC_DFI_NDL/SVC_DFI_NDL_password"
  fsx_domain                = "${var.environment_name}.local"
}

#Creating by aws cli as some features are currently not present via Terraform ie schedule
resource "null_resource" "s3_to_efs_sync_task" {
  triggers = {
    region = var.region
    name   = local.name
  }
  provisioner "local-exec" {
    command = "sh scripts/create_data-sync-task.sh ${var.region} ${local.source-location-arn}  ${local.cloud-watch-log-group-arn} ${local.name} ${local.fsx-sg-arn} ${local.ad_user_param} ${local.ad_pass_param} ${local.fsx_domain}"
  }
 }
