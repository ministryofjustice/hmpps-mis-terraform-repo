####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################
locals {
  common_name      = "${var.common_name}"
  tags             = "${var.tags}"
  s3-config-bucket = "${var.s3-config-bucket}"
  artefact-bucket  = "${var.artefact-bucket}"
  region           = "${var.region}"
  account_id       = "${var.account_id}"
}

############################################
# CREATE IAM POLICIES
############################################

#-------------------------------------------------------------
### INTERNAL IAM POLICES FOR EC2 RUNNING ECS SERVICES
#-------------------------------------------------------------

data "template_file" "iam_policy_app_int" {
  template = "${var.ec2_internal_policy_file}"

  vars {
    s3-config-bucket   = "${local.s3-config-bucket}"
    s3-artefact-bucket = "${local.artefact-bucket}"
    app_role_arn       = "${module.create-iam-app-role-int.iamrole_arn}"
    runtime_role       = "${var.runtime_role}"
    ssm_prefix         = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${local.common_name}*"
  }
}

module "create-iam-app-role-int" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//iam//role"
  rolename   = "${local.common_name}-ec2"
  policyfile = "${var.ec2_policy_file}"
}

module "create-iam-instance-profile-int" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//iam//instance_profile"
  role   = "${module.create-iam-app-role-int.iamrole_name}"
}

module "create-iam-app-policy-int" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//iam//rolepolicy"
  policyfile = "${data.template_file.iam_policy_app_int.rendered}"
  rolename   = "${module.create-iam-app-role-int.iamrole_name}"
}
