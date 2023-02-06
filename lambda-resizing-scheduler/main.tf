

#------------------------------------------------------------------------------------------------------------------
# Lambda function
#------------------------------------------------------------------------------------------------------------------

data "archive_file" "lambda_scheduler" {
  type               = "zip"
  source_file        = "${path.module}/lambda/mis-modify-ec2-instance-type.py"
  output_path        = "${path.module}/files/mis-modify-ec2-instance-type.zip"
}

resource "aws_lambda_function" "modify-ec2-instance-type" {
  filename         = data.archive_file.lambda_scheduler.output_path
  function_name    = local.lambda_name
  role             = aws_iam_role.modify-ec2-instance-type.arn
  handler          = "${local.lambda_name}.handler"
  source_code_hash = filebase64sha256(data.archive_file.lambda_scheduler.output_path)
  runtime          = "python3.8"
  timeout          = 300 
  
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

