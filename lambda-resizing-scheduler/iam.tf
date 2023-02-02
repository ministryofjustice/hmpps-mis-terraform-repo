#------------------------------------------------------------------------------------------------------------------
# Scheduler Lambda IAM role & policy
#------------------------------------------------------------------------------------------------------------------

data "template_file" "lambda_scheduler" {
  template = "${file("./templates/modify-ec2-instance-type-lambda-policy.tpl")}"

  vars = {
    environment_name = var.environment_name
    region           = var.region
    account_id       = local.account_id
  }
}

resource "aws_iam_policy" "lambda_scheduler" {
  name        = "${var.environment_name}-${local.app_name}-modify-ec2-instance-role"
  path        = "/"
  description = "${var.environment_name}-${local.app_name}-modify-ec2-instance-role"
  policy      = data.template_file.lambda_scheduler.rendered
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

resource "aws_iam_role_policy" "lambda_logging" {
  name  = "${var.environment_name}-lambda-logging"
  role  = "${aws_iam_role.modify-ec2-instance-type.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_scheduler" {
  role       = aws_iam_role.modify-ec2-instance-type.name
  policy_arn = aws_iam_policy.lambda_scheduler.arn
}

#------------------------------------------------------------------------------------------------------------------
# Notify Slack Lambda IAM role & policy
#------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambda_notify_scheduler_role" {
  name               = "${var.environment_name}-scheduler-notify-slack-role"
  description        = "Role enabling Lambda to access Slack for sending alerts and enabling Lambda ro access SSM Parameter Store slack token value"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  tags               = merge(var.tags, 
  { 
    Name = "${var.environment_name}-scheduler-notify-slack-role" 
  }
)
}

resource "aws_iam_policy" "lambda_notify_scheduler_policy" {
  name   = "${var.environment_name}-scheduler-notify-slack-role"
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_notify_scheduler_policy" {
  role       = aws_iam_role.lambda_notify_scheduler_role.name
  policy_arn = aws_iam_policy.lambda_notify_scheduler_policy.arn
}