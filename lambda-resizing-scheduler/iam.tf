#------------------------------------------------------------------------------------------------------------------
# Scheduler Lambda IAM role & policy
#------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "lambda_scheduler" {
  name        = "${var.environment_name}-${local.app_name}-modify-ec2-instance-role"
  path        = "/"
  description = "${var.environment_name}-${local.app_name}-modify-ec2-instance-role"
  policy      = "${file("./templates/modify-ec2-instance-type-lambda-policy.tpl")}" 
}

resource "aws_iam_role" "modify-ec2-instance-type" {
  name               = "${var.environment_name}-${local.app_name}-modify-ec2-instance-role"
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
    local.tags,
    {
      "Name" = "${var.environment_name}-${local.lambda_name}"
    },
  )
}

resource "aws_iam_role_policy_attachment" "lambda_scheduler" {
  role       = aws_iam_role.modify-ec2-instance-type.name
  policy_arn = aws_iam_policy.lambda_scheduler.arn
}

