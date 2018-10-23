####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

####################################################
# Locals
####################################################

locals {
  common_name = "${var.environment_identifier}-${var.app_name}"
  tags        = "${var.tags}"
}

############################################
# S3 Buckets
############################################

# #-------------------------------------------
# ### S3 bucket for artefacts
# #-------------------------------------------

module "s3bucket" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//s3bucket//s3bucket_without_policy"
  s3_bucket_name = "${local.common_name}-artefacts"
  tags           = "${local.tags}"
}
