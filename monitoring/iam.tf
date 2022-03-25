resource "aws_iam_role" "lambda_role" {
  name               = "${var.environment_name}-notify-slack-role"
  description        = "Role enabling Lambda to access Slack for sending alerts and enabling Lambda ro access SSM Parameter Store slack token value"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  tags               = merge(var.tags, { Name = "${var.environment_name}-notify-slack-role" })
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.environment_name}-notify-slack-role"
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
