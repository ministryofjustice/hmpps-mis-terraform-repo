resource "aws_scheduler_schedule" "stop" {
  name                = "${var.environment_name}-${local.app_name}-lb-management-stop-schedule"
  description         = "Schedule to enable banner on MIS LB during ETL/Maintenance"
  schedule_expression = var.lb_mgmt_stop_expression
  state               = var.lb_management_rule_enabled ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.environment_name}-${local.app_name}-lb-rule-mgmt-build"
    role_arn = aws_iam_role.lb_mgmt.arn
    input = jsonencode({
      environmentVariablesOverride : [
        {
          name : "ACTION",
          value : "stop"
        }
      ]
    })
  }
}

resource "aws_scheduler_schedule" "resume" {
  name                = "${var.environment_name}-${local.app_name}-lb-management-resume-schedule"
  description         = "Schedule to remove banner on MIS LB during ETL/Maintenance completion"
  schedule_expression = var.lb_mgmt_resume_expression
  state               = var.lb_management_rule_enabled ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.environment_name}-${local.app_name}-lb-rule-mgmt-build"
    role_arn = aws_iam_role.lb_mgmt.arn
    input = jsonencode({
      environmentVariablesOverride : [
        {
          name : "ACTION",
          value : "resume"
        }
      ]
    })
  }
}

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

resource "aws_iam_role_policy_attachment" "lb_mgmt" {
  role       = aws_iam_role.lb_mgmt.name
  policy_arn = aws_iam_policy.lb_mgmt.arn
}
