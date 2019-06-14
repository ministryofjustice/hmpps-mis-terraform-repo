resource "aws_security_group_rule" "smtp_in" {
  from_port          = 25
  protocol           = "tcp"
  security_group_id  = "${local.sg_mis_common}"
  to_port            = 25
  type               = "ingress"
  description        = "${local.common_name}-SMTP"
  cidr_blocks = [
    "${local.private_cidr_block}",
  ]
}

resource "aws_security_group_rule" "ses_out" {
  from_port          = 587
  protocol           = "tcp"
  security_group_id  = "${local.sg_outbound_id}"
  to_port            = 587
  type               = "egress"
  description        = "${local.common_name}-SES"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "smtp_host_relay" {
  from_port          = 25
  protocol           = "tcp"
  security_group_id  = "${local.sg_outbound_id}"
  to_port            = 25
  type               = "egress"
  description        = "${local.common_name}-SMTP"
  cidr_blocks = [
    "${local.private_cidr_block}",
  ]
}
