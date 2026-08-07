resource "aws_route53_record" "modernisation_platform_reporting_cname" {
  count = var.modernisation_platform_mis_cname != null ? 1 : 0

  zone_id = local.public_zone_id
  name    = "reporting.${local.external_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [var.modernisation_platform_mis_cname]
}

resource "aws_route53_record" "modernisation_platform_reporting_admin_cname" {
  count = var.modernisation_platform_mis_cname != null ? 1 : 0

  zone_id = local.public_zone_id
  name    = "admin.reporting.${local.external_domain}"
  type    = "CNAME"
  ttl     = 300
  records = ["admin.${var.modernisation_platform_mis_cname}"]
}

resource "aws_route53_record" "modernisation_platform_reporting_external_validation" {
  count = var.modernisation_platform_mis_cert_validation_name != null ? 1 : 0

  zone_id = local.public_zone_id
  name    = var.modernisation_platform_mis_cert_validation_name
  type    = "CNAME"
  ttl     = 300
  records = [var.modernisation_platform_mis_cert_validation_value]
}
