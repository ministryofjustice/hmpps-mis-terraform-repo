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
### Getting bws instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bws" {
    backend = "s3"

    config = {
        bucket = var.remote_state_bucket_name
        key    = "${var.environment_type}/ec2-ndl-bws/terraform.tfstate"
        region = var.region
    }
}

#-------------------------------------------------------------
### Getting dis instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-dis" {
    backend = "s3"

    config = {
        bucket = var.remote_state_bucket_name
        key    = "${var.environment_type}/ec2-ndl-dis/terraform.tfstate"
        region = var.region
    }
}

#-------------------------------------------------------------
### Getting bps instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bps" {
    backend = "s3"

    config = {
        bucket = var.remote_state_bucket_name
        key    = "${var.environment_type}/ec2-ndl-bps/terraform.tfstate"
        region = var.region
    }
}

#-------------------------------------------------------------
### Getting bcs instance details
#-------------------------------------------------------------
data "terraform_remote_state" "ec2-ndl-bcs" {
    backend = "s3"

    config = {
        bucket = var.remote_state_bucket_name
        key    = "${var.environment_type}/ec2-ndl-bcs/terraform.tfstate"
        region = var.region
    }
}

#-------------------------------------------------------------
### Getting nextcloud details
#-------------------------------------------------------------
data "terraform_remote_state" "nextcloud" {
    backend = "s3"

    config = {
        bucket = var.remote_state_bucket_name
        key    = "${var.environment_type}/nextcloud/terraform.tfstate"
        region = var.region
    }
}


#-------------------------------------------------------------
### Dashboard
#-------------------------------------------------------------
data "template_file" "dashboard-body" {
    template = file("dashboard.json")
    vars = {
        region             = var.region
        environment_name   = var.environment_type
        bws_lb_name        = local.bws_lb_name
        region             = var.region
        slow_latency       = 1
        nextcloud_lb_name  = local.nextcloud_lb_name
        bws_elb_arn_suffix = local.bws_elb_arn_suffix
        target_group_arn_suffix = local.target_group_arn_suffix
    }
}

#-------------------------------------------------------------
### Lambda
#-------------------------------------------------------------
data "archive_file" "notify-ndmis-slack" {
    type        = "zip"
    source_file = "${path.module}/lambda/${local.lambda_name}.js"
    output_path = "${path.module}/files/${local.lambda_name}zip"
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
        resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${aws_ssm_parameter.slack_token.name}"]
        actions   = ["ssm:GetParameter"]
    }
    statement {
        sid       = "ParameterDecryption"
        effect    = "Allow"
        resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/aws/ssm"]
        actions   = ["kms:Decrypt"]
    }
}