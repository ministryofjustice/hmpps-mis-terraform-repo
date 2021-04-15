locals {
  lambda_name = "dfi-lambda-function"
}

#--------------------------------------------------------
#Lambda Handler
#--------------------------------------------------------
data "archive_file" "dfi_lambda" {
  type        = "zip"
  output_path = "${path.module}/files/${local.lambda_name}.zip"
  source_file = "${path.module}/lambda/${local.lambda_name}.py"
}

#--------------------------------------------------------
#Lambda IAM
#--------------------------------------------------------
data "template_file" "dfi_lambda" {
  template = "${file("./templates/dfi-lambda-policy.tpl")}"

  vars = {
    environment_name = var.environment_name
    region           = var.region
    account_id       = local.account_id
  }
}

resource "aws_iam_policy" "dfi_lambda" {
  name        = "${var.environment_name}-${local.lambda_name}"
  path        = "/"
  description = "${var.environment_name}-${local.lambda_name}"
  policy      = data.template_file.dfi_lambda.rendered
}

resource "aws_iam_role" "dfi_lambda" {
  name = "${var.environment_name}-${local.lambda_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
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
      "Name" = "${var.environment_name}-${local.lambda_name}"
    },
  )
}

resource "aws_iam_role_policy_attachment" "dfi_lambda" {
  role       = aws_iam_role.dfi_lambda.name
  policy_arn = aws_iam_policy.dfi_lambda.arn
}

#--------------------------------------------------------
#Lambda Function
#--------------------------------------------------------

resource "aws_cloudwatch_log_group" "dfi_lambda" {
  name              = local.dfi_lambda_log_group
  retention_in_days = "14"
  tags = merge(
    var.tags,
    {
      "Name" = local.dfi_lambda_log_group
    },
  )
}

resource "aws_lambda_function" "dfi_lambda" {
  filename         = data.archive_file.dfi_lambda.output_path
  function_name    = local.lambda_name
  role             = aws_iam_role.dfi_lambda.arn
  handler          = "${local.lambda_name}.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.dfi_lambda.output_path)
  runtime          = "python3.7"

  environment {
    variables = {
      CODE_PIPELINE_NAME = "${var.environment_name}-dfi-s3-fsx"
    }
  }
}

resource "aws_lambda_permission" "with_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dfi_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.dfi.arn
}

#--------------------------------------------------------
#S3 Event Notification
#--------------------------------------------------------
resource "aws_s3_bucket_notification" "dfi_lambda" {
  bucket = aws_s3_bucket.dfi.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.dfi_lambda.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "dfinterventions/dfi"
  }
  depends_on = [aws_lambda_permission.with_s3]
}
