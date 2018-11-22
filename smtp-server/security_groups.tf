resource "aws_security_group_rule" "smtp_out_relay" {
  from_port = 25
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.common.sg_map_ids["sg_mis_common"]}"
  to_port = 25
  type = "egress"

  source_security_group_id = "${aws_security_group.mis_smtp_host.id}"
}

resource "aws_security_group_rule" "smtp_out_deprecated" {
  from_port = 465
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.common.sg_map_ids["sg_mis_common"]}"
  to_port = 465
  type = "egress"

  source_security_group_id = "${aws_security_group.mis_smtp_host.id}"
}

resource "aws_security_group_rule" "smtp_out_submission" {
  from_port = 587
  protocol = "tcp"
  security_group_id = "${data.terraform_remote_state.common.sg_map_ids["sg_mis_common"]}"
  to_port = 587
  type = "egress"

  source_security_group_id = "${aws_security_group.mis_smtp_host.id}"
}

####Smtp host security group

resource "aws_security_group_rule" "smtp_host_relay" {
  from_port = 25
  protocol = "tcp"
  security_group_id = "${aws_security_group.mis_smtp_host.id}"
  to_port = 25
  type = "ingress"

  source_security_group_id = "${data.terraform_remote_state.common.sg_map_ids["sg_mis_common"]}"
}

resource "aws_security_group_rule" "smtp_host_deprecated" {
  from_port = 465
  protocol = "tcp"
  security_group_id = "${aws_security_group.mis_smtp_host.id}"
  to_port = 465
  type = "ingress"

  source_security_group_id = "${data.terraform_remote_state.common.sg_map_ids["sg_mis_common"]}"
}

resource "aws_security_group_rule" "smtp_host_submission" {
  from_port = 587
  protocol = "tcp"
  security_group_id = "${aws_security_group.mis_smtp_host.id}"
  to_port = 587
  type = "ingress"

  source_security_group_id = "${data.terraform_remote_state.common.sg_map_ids["sg_mis_common"]}"
}

resource "aws_security_group_rule" "smtp_host_ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.mis_smtp_host.id}"
  to_port = 22
  type = "ingress"
  source_security_group_id = "${data.terraform_remote_state.common.sg_map_ids["sg_mis_jumphost"]}"
}

resource "aws_security_group_rule" "smtp_host_world_out" {
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.mis_smtp_host.id}"
  to_port = 0
  type = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "mis_smtp_host" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-smtp-host"
  vpc_id      = "${data.terraform_remote_state.common.vpc_id}"
  description = "smtp-host-sg"
  tags        = "${merge(data.terraform_remote_state.common.common_tags, map("Name", "${var.environment_name}_${var.mis_app_name}_smtp_host", "Type", "SMTP"))}"

  lifecycle {
    create_before_destroy = true
  }
}