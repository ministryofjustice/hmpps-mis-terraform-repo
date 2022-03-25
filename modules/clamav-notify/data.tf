### Region
data "aws_region" "current" {
}

### Slack token URL details
data "aws_ssm_parameter" "slack_token" {
  name            = "/${var.name}/slack/token"
}

### Lambda
data "archive_file" "clamav-notification" {
  type        = "zip"
  source_file = "${path.module}/lambda/${local.clamav_notification}.js"
  output_path = "${path.module}/files/${local.clamav_notification}.zip"
}

### IAM
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
        resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.name}/slack/token"]
        actions   = ["ssm:GetParameter"]
    }
    statement {
        sid       = "ParameterDecryption"
        effect    = "Allow"
        resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/ssm"]
        actions   = ["kms:Decrypt"]
    }
}