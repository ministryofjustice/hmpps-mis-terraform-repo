####################################################
# IAM - Application specific
####################################################

# APP ROLE
output "iam_policy_int_app_role_name" {
  value = "${module.iam.iam_policy_int_app_role_name}"
}

output "iam_policy_int_app_role_arn" {
  value = "${module.iam.iam_policy_int_app_role_arn}"
}

# PROFILE
output "iam_policy_int_app_instance_profile_name" {
  value = "${module.iam.iam_policy_int_app_instance_profile_name}"
}

# ldap
output "iam_policy_int_ldap_role_name" {
  value = "${module.ldap.iam_policy_int_app_role_name}"
}

output "iam_policy_int_ldap_role_arn" {
  value = "${module.ldap.iam_policy_int_app_role_arn}"
}

# PROFILE
output "iam_policy_int_ldap_instance_profile_name" {
  value = "${module.ldap.iam_policy_int_app_instance_profile_name}"
}

# jump host
output "iam_policy_int_jumphost_role_name" {
  value = "${module.jumphost.iam_policy_int_app_role_name}"
}

output "iam_policy_int_jumphost_role_arn" {
  value = "${module.jumphost.iam_policy_int_app_role_arn}"
}

# PROFILE
output "iam_policy_int_jumphost_instance_profile_name" {
  value = "${module.jumphost.iam_policy_int_app_instance_profile_name}"
}

# MIS DB ROLE
output "iam_policy_int_mis_db_role_name" {
  value = "${module.mis_db.iam_policy_int_app_role_name}"
}

output "iam_policy_int_mis_db_role_arn" {
  value = "${module.mis_db.iam_policy_int_app_role_arn}"
}

# PROFILE
output "iam_policy_int_mis_db_instance_profile_name" {
  value = "${module.mis_db.iam_policy_int_app_instance_profile_name}"
}

#EC2 Backups
output "mis_ec2_backup_role_arn" {
  value = "${aws_iam_role.mis_ec2_backup_role.arn}"
}
