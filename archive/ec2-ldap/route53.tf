####################################################
# Route53 records - FreeIPA
####################################################

#-------------------------------------------------------------
# TXT Records
#-------------------------------------------------------------

resource "aws_route53_record" "txt_kerberos" {
  zone_id = "${local.private_zone_id}"
  name    = "_kerberos.${local.internal_domain}"
  type    = "TXT"
  ttl     = "300"
  records = ["${local.internal_domain}"]
}

#-------------------------------------------------------------
# SRV Records
#-------------------------------------------------------------

# _kerberos-master._tcp
resource "aws_route53_record" "srv_master_kerb_tcp" {
  zone_id = "${local.private_zone_id}"
  name    = "_kerberos-master._tcp.${local.internal_domain}"
  type    = "SRV"
  ttl     = "300"

  records = [
    "0 100 88 ${local.ldap_primary}.${local.internal_domain}",
    "0 101 88 ${local.ldap_replica}.${local.internal_domain}",
  ]
}

# _kerberos-master._udp
resource "aws_route53_record" "srv_master_kerb_udp" {
  zone_id = "${local.private_zone_id}"
  name    = "_kerberos-master._udp.${local.internal_domain}"
  type    = "SRV"
  ttl     = "300"

  records = [
    "0 100 88 ${local.ldap_primary}.${local.internal_domain}",
    "0 101 88 ${local.ldap_replica}.${local.internal_domain}",
  ]
}

# _kerberos._tcp
resource "aws_route53_record" "srv_kerb_tcp" {
  zone_id = "${local.private_zone_id}"
  name    = "_kerberos._tcp.${local.internal_domain}"
  type    = "SRV"
  ttl     = "300"

  records = [
    "0 100 88 ${local.ldap_primary}.${local.internal_domain}",
    "0 101 88 ${local.ldap_replica}.${local.internal_domain}",
  ]
}

# _kerberos._udp
resource "aws_route53_record" "srv_kerb_udp" {
  zone_id = "${local.private_zone_id}"
  name    = "_kerberos._udp.${local.internal_domain}"
  type    = "SRV"
  ttl     = "300"

  records = [
    "0 100 88 ${local.ldap_primary}.${local.internal_domain}",
    "0 101 88 ${local.ldap_replica}.${local.internal_domain}",
  ]
}

# _kpasswd._tcp
resource "aws_route53_record" "srv_kpasswd_tcp" {
  zone_id = "${local.private_zone_id}"
  name    = "_kpasswd._tcp.${local.internal_domain}"
  type    = "SRV"
  ttl     = "300"
  records = ["0 100 464 ${local.ldap_primary}.${local.internal_domain}"]
}

# _kpasswd._udp
resource "aws_route53_record" "srv_kpasswd_udp" {
  zone_id = "${local.private_zone_id}"
  name    = "_kpasswd._udp.${local.internal_domain}"
  type    = "SRV"
  ttl     = "300"
  records = ["0 100 464 ${local.ldap_primary}.${local.internal_domain}"]
}

# _ldap._tcp.
resource "aws_route53_record" "srv_ldap_tcp" {
  zone_id = "${local.private_zone_id}"
  name    = "_ldap._tcp.${local.internal_domain}"
  type    = "SRV"
  ttl     = "300"
  records = ["0 100 389 ${local.ldap_primary}.${local.internal_domain}"]
}

# _ntp._udp.
resource "aws_route53_record" "srv_ntp_udp" {
  zone_id = "${local.private_zone_id}"
  name    = "_ntp._udp.${local.internal_domain}"
  type    = "SRV"
  ttl     = "300"
  records = ["0 100 123 ${local.ldap_primary}.${local.internal_domain}"]
}
