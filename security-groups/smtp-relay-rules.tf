resource "aws_security_group_rule" "ses_out" {
  from_port          = 587
  protocol           = "tcp"
  security_group_id  = "${local.sg_outbound_id}"
  to_port            = 587
  type               = "egress"
  description        = "${local.environment_identifier}-ses"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
