terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
    backend = "s3"

    config = {
        bucket = var.remote_state_bucket_name
        key    = "${var.environment_type}/common/terraform.tfstate"
        region = var.region
    }
}

#-------------------------------------------------------------
### Getting SSM secrets
#-------------------------------------------------------------
data "terraform_remote_state" "monitoring" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "${var.environment_type}/monitoring/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Notify Lambda 
#-------------------------------------------------------------
data "archive_file" "notify-ndmis-slack" {
    type        = "zip"
    source_file = "${path.module}/lambda/${local.lambda_notify_slack_name}.js"
    output_path = "${path.module}/files/${local.lambda_notify_slack_name}zip"
}

#-------------------------------------------------------------
### IAM resources
#-------------------------------------------------------------
data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "assume_role_policy_document" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "lambda_policy_document" {
    statement {
        sid       = "Logging"
        effect    = "Allow"
        resources = ["*"]
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
    }
    statement {
        sid       = "Parameters"
        effect    = "Allow"
        resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${local.slack_token_name}"]
        actions   = ["ssm:GetParameter"]
    }
    statement {
        sid       = "ParameterDecryption"
        effect    = "Allow"
        resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/aws/ssm"]
        actions   = ["kms:Decrypt"]
    }
}