# LOCALS 
locals {
  role_arn     = "${var.role_arn}"
  common_name  = "${var.environment_identifier}-${var.app_name}"
  ecr_policy   = "${var.ecr_policy}"
  eng_root_arn = "${var.eng_root_arn}"
}

############################################
# CREATE ECR FOR APPS
############################################
data "template_file" "ecr_policy" {
  template = "${file("${local.ecr_policy}")}"

  vars {
    role_arn     = "${local.role_arn}"
    eng_root_arn = "${local.eng_root_arn}"
  }
}

module "ecr" {
  source   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ecr"
  app_name = "${local.common_name}"
  policy   = "${data.template_file.ecr_policy.rendered}"
}
