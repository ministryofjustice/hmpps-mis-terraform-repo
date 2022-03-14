resource "aws_iam_role" "lambda_role" {
  name               = "${var.name}-clamav-notify-slack-role"
  description        = "Role enabling Lambda to access Slack for sending alerts and enabling Lambda ro access SSM Parameter Store slack token value"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  tags               = merge(var.tags, { Name = "${var.name}-notify-slack-role" })
}

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
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/mis/*/slack/token"]
    actions   = ["ssm:GetParameter"]
  }
  statement {
    sid       = "ParameterDecryption"
    effect    = "Allow"
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/aws/ssm"]
    actions   = ["kms:Decrypt"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.name}-notify-slack-role"
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
