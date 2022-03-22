### Slack Token SSM ParamStore

resource "random_password" "slack_webhook_url" {
  length           = 32
  special          = false
}

resource "aws_ssm_parameter" "slack_token" {
  name            = "/${var.environment_type}/slack/token"
  type            = "SecureString"
  value           = random_password.slack_webhook_url.result
  tags            = merge(
    var.tags, 
    {
      "Name" = "/${var.environment_type}/slack/token" 
    }
  )

  lifecycle {
    ignore_changes = [value]
  }
}