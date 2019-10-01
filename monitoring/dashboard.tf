resource "aws_cloudwatch_dashboard" "mis" {
  dashboard_name = "mis-${local.environment_name}-monitoring"
  dashboard_body = "${data.template_file.dashboard-body.rendered}"
}

data "template_file" "dashboard-body" {
  template = "${file("dashboard.json")}"
  vars {
    region            = "${var.region}"
    environment_name  = "${local.environment_name}"
    bws_lb_name       = "${local.bws_lb_name}"
  }
}
