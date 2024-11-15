####################################################
# SG Rules for lb
####################################################

### HTTPS in
resource "aws_security_group_rule" "https_in" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_lb
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  description       = "TF - HTTPS in to LB"

  cidr_blocks = concat(
    local.user_access_cidr_blocks,
    local.env_user_access_cidr_blocks,
    local.natgateway_az1,
    local.natgateway_az2,
    local.natgateway_az3,
    local.bastion_public_ip,
  )
}

resource "aws_security_group_rule" "http_in" {
  security_group_id        = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_lb
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "egress"
  description              = "Lb out to nextcloud"
  source_security_group_id = data.terraform_remote_state.security-groups.outputs.sg_https_out
}

####################################################
# SG Rules for ASG
####################################################

resource "aws_security_group_rule" "asg_http_in" {
  security_group_id        = data.terraform_remote_state.security-groups.outputs.sg_mis_app_in
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "HTTP in from LB"
  source_security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_lb
}

####################################################
# SG Rules for EFS Share
####################################################

resource "aws_security_group_rule" "nextcloud_efs_in" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_efs_in
  from_port         = "2049"
  to_port           = "2049"
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-efs-in"
  self              = "true"
}

resource "aws_security_group_rule" "nextcloud_efs_out" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_efs_in
  from_port         = "2049"
  to_port           = "2049"
  protocol          = "tcp"
  type              = "egress"
  description       = "${local.common_name}-efs-out"
  self              = "true"
}

####################################################
# SG Rules for DB
####################################################

resource "aws_security_group_rule" "nextcloud_db_in" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_db
  from_port         = "3306"
  to_port           = "3306"
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-db-in"
  self              = "true"
}

resource "aws_security_group_rule" "nextcloud_db_out" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_db
  from_port         = "3306"
  to_port           = "3306"
  protocol          = "tcp"
  type              = "egress"
  description       = "${local.common_name}-db-out"
  self              = "true"
}

resource "aws_security_group_rule" "jenkins_db_in" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_nextcloud_db
  from_port         = "3306"
  to_port           = "3306"
  protocol          = "tcp"
  type              = "ingress"
  description       = "jenkins-db-in"
  cidr_blocks = [
    "10.161.96.0/24",
  ]
}

####################################################
# SG Rules for ldap
####################################################

resource "aws_security_group_rule" "ldap_in" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_https_out
  from_port         = 389
  to_port           = 389
  protocol          = "tcp"
  type              = "ingress"
  description       = "nextcloud in to MP ldap range"
  # source_security_group_id = data.terraform_remote_state.security-groups.outputs.sg_https_out
  cidr_blocks = [
    "10.26.24.0/21",
    "10.26.8.0/21",
    "10.27.0.0/21",
    "10.27.8.0/21"
  ]
}

resource "aws_security_group_rule" "ldap_out" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_https_out
  from_port         = 389
  to_port           = 389
  protocol          = "tcp"
  type              = "egress"
  description       = "nextcloud in to MP ldap range"
  # source_security_group_id = data.terraform_remote_state.delius_core_security_groups.outputs.sg_apacheds_ldap_private_elb_id
  cidr_blocks = [
    "10.26.24.0/21",
    "10.26.8.0/21",
    "10.27.0.0/21",
    "10.27.8.0/21"
  ]
}

resource "aws_security_group_rule" "ldap_in_secure" {
  security_group_id = data.terraform_remote_state.delius_core_security_groups.outputs.sg_apacheds_ldap_private_elb_id
  from_port         = 636
  to_port           = 636
  protocol          = "tcp"
  type              = "ingress"
  description       = "nextcloud in to MP ldap range"
  # source_security_group_id = data.terraform_remote_state.security-groups.outputs.sg_https_out
  cidr_blocks = [
    "10.26.24.0/21",
    "10.26.8.0/21",
    "10.27.0.0/21",
    "10.27.8.0/21"
  ]
}

resource "aws_security_group_rule" "ldap_out_secure" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_https_out
  from_port         = 636
  to_port           = 636
  protocol          = "tcp"
  type              = "egress"
  description       = "nextcloud in to MP ldap range"
  # source_security_group_id = data.terraform_remote_state.delius_core_security_groups.outputs.sg_apacheds_ldap_private_elb_id
  cidr_blocks = [
    "10.26.24.0/21",
    "10.26.8.0/21",
    "10.27.0.0/21",
    "10.27.8.0/21"
  ]
}


####################################################
# SG Rules for Redis cache
####################################################

resource "aws_security_group_rule" "nextcloud_redis_out" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_https_out
  from_port         = "6379"
  to_port           = "6379"
  protocol          = "tcp"
  type              = "egress"
  description       = "${local.common_name}-redis-out"
  self              = "true"
}

resource "aws_security_group_rule" "nextcloud_redis_in" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_https_out
  from_port         = "6379"
  to_port           = "6379"
  protocol          = "tcp"
  type              = "ingress"
  description       = "${local.common_name}-redis-in"
  self              = "true"
}

####################################################
# SG Rules for samba share
####################################################

resource "aws_security_group_rule" "samba_in" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_samba
  from_port         = 445
  to_port           = 445
  protocol          = "tcp"
  type              = "ingress"
  description       = "SMB in from LB"
  self              = "true"
}

resource "aws_security_group_rule" "samba_out" {
  security_group_id = data.terraform_remote_state.security-groups.outputs.sg_mis_samba
  from_port         = 445
  to_port           = 445
  protocol          = "tcp"
  type              = "egress"
  description       = "SMB out to LB"
  self              = "true"
}
