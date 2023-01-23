locals {
  environment_identifier              = data.terraform_remote_state.common.outputs.short_environment_identifier
  app_name                            = data.terraform_remote_state.common.outputs.mis_app_name
  lambda_name                         = "${local.app_name}-modify-ec2-instance-type"
  tags                                = data.terraform_remote_state.common.outputs.common_tags
  account_id                          = data.terraform_remote_state.common.outputs.common_account_id
  enable_resizing_schedule            = var.mis_overide_resizing_schedule_tags
  dis_instance_type_am                = var.dis_instance_type_lower
  dis_instance_type_pm                = var.dis_instance_type
  }

#------------------------------------------------------------------------------------------------------------------
# Lambda IAM role & policy
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

resource "aws_iam_role_policy_attachment" "lambda_scheduler" {
  role       = aws_iam_role.modify-ec2-instance-type.name
  policy_arn = aws_iam_policy.lambda_scheduler.arn
}

#------------------------------------------------------------------------------------------------------------------
# Lambda function AM
#------------------------------------------------------------------------------------------------------------------

data "archive_file" "lambda_scheduler" {
  type               = "zip"
  source_file        = "${path.module}/lambda/modify-ec2-instance-type.py"
  output_path        = "${path.module}/files/modify-ec2-instance-type.zip"
}

resource "aws_lambda_function" "modify-ec2-instance-type" {
  filename         = data.archive_file.lambda_scheduler.output_path
  function_name    = local.lambda_name
  role             = aws_iam_role.modify-ec2-instance-type.arn
  handler          = "${local.lambda_name}.handler"
  source_code_hash = filebase64sha256(data.archive_file.lambda_scheduler.output_path)
  runtime          = "python3.8"
  
  environment {
    variables = {
      REGION                   = var.region
      ENVIRONMENT_TYPE         = var.environment_type
      ENABLE_RESIZE_SCHEDULE   = local.enable_resizing_schedule
    }
  }
}

#------------------------------------------------------------------------------------------------------------------
# Event Rules
#------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "resizing_schedule_am" {
  name                = "${var.environment_name}-${local.app_name}-resizing-schedule-am"
  description         = "Rule to run resizing schedule lambda script in the morning (AM)"
  schedule_expression = var.resizing_schedule_am_expression
  is_enabled          = local.enable_resizing_schedule
}

resource "aws_cloudwatch_event_rule" "resizing_schedule_pm" {
  name                = "${var.environment_name}-${local.app_name}-resizing-schedule-pm"
  description         = "Rule to run resizing schedule lambda script in the evening (PM)"
  schedule_expression = var.resizing_schedule_pm_expression
  is_enabled          = local.enable_resizing_schedule
}

#------------------------------------------------------------------------------------------------------------------
# Event Rule Targets
#------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "resizing_schedule_am" {
  arn      = "${aws_lambda_function.modify-ec2-instance-type.arn}"
  rule     = aws_cloudwatch_event_rule.resizing_schedule_am.name
  target_id = "${aws_lambda_function.modify-ec2-instance-type.id}AM"
  input     = <<JSON
    {
      "ec2type": "${local.dis_instance_type_am}"
    } 
  JSON
}

resource "aws_cloudwatch_event_target" "resizing_schedule_pm" {
  arn      = "${aws_lambda_function.modify-ec2-instance-type.arn}"
  rule     = aws_cloudwatch_event_rule.resizing_schedule_pm.name
  target_id = "${aws_lambda_function.modify-ec2-instance-type.id}PM"
  input     = <<JSON
    {
      "ec2type": "${local.dis_instance_type_pm}"
    } 
  JSON

  depends_on = [aws_cloudwatch_event_target.resizing_schedule_am] // delay creation of the second  sender CW event to prevent ConcurrentModificationException
}

#------------------------------------------------------------------------------------------------------------------
# Lambda Permissions
#------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_cloudwatch_scheduler_am" {
  statement_id  = "AllowExecutionFromCloudWatch1"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.modify-ec2-instance-type.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.resizing_schedule_am.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_scheduler_pm" {
  statement_id  = "AllowExecutionFromCloudWatch2"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.modify-ec2-instance-type.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.resizing_schedule_pm.arn}"
}