#-----------------------------------------
# Event
#-----------------------------------------
resource "aws_cloudwatch_event_rule" "stop" {
  name                = "${var.environment_name}-${local.app_name}-lb-management-stop-event-rule"
  description         = "Rule to enable banner on MIS LB during ETL/Maintenance"
  schedule_expression = var.lb_mgmt_stop_expression
  is_enabled          = var.lb_management_rule_enabled
}

resource "aws_cloudwatch_event_rule" "resume" {
  name                = "${var.environment_name}-${local.app_name}-lb-management-resume-event-rule"
  description         = "Rule to remove banner on MIS LB after ETL/Maintenance completion"
  schedule_expression = var.lb_mgmt_resume_expression
  is_enabled          = var.lb_management_rule_enabled
}

#-----------------------------------------
# Event Targets
#-----------------------------------------
resource "aws_cloudwatch_event_target" "stop" {
  arn      = "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.environment_name}-${local.app_name}-lb-rule-mgmt-build"
  rule     = aws_cloudwatch_event_rule.stop.name
  role_arn = aws_iam_role.lb_mgmt.arn

  input = <<DOC
  {
  "environmentVariablesOverride": [
    {
      "name": "ACTION",
      "value": "stop"
    }
   ]
   }
  DOC
}

resource "aws_cloudwatch_event_target" "resume" {
  arn      = "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.environment_name}-${local.app_name}-lb-rule-mgmt-build"
  rule     = aws_cloudwatch_event_rule.resume.name
  role_arn = aws_iam_role.lb_mgmt.arn

  input = <<DOC
  {
  "environmentVariablesOverride": [
    {
      "name": "ACTION",
      "value": "resume"
    }
   ]
   }
  DOC
}

#-----------------------------------------
# IAM Role
#-----------------------------------------

resource "aws_iam_role" "lb_mgmt" {
  name               = "${var.environment_name}-${local.app_name}-lb-management-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

#-----------------------------------------
# IAM Policy
#-----------------------------------------

resource "aws_iam_policy" "lb_mgmt" {
  name        = "${var.environment_name}-${local.app_name}-lb-management-policy"
  description = "Policy to allow Event rule to invoke Codebuild project ${var.environment_name}-${local.app_name}-lb-rule-mgmt-build"

policy = <<POLICY
{
"Version": "2012-10-17",
"Statement": [
{
      "Effect": "Allow",
      "Action": ["codebuild:StartBuild"],
      "Resource": ["arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.environment_name}-${local.app_name}-lb-rule-mgmt-build"]
          }
      ]
  }

POLICY

}

#-----------------------------------------
# IAM Policy Attachment
#-----------------------------------------
resource "aws_iam_role_policy_attachment" "lb_mgmt" {
  role       = aws_iam_role.lb_mgmt.name
  policy_arn = aws_iam_policy.lb_mgmt.arn
}
