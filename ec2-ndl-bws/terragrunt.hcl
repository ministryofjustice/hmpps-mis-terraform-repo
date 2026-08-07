include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../common", "../securty-groups", "../iam", "../s3buckets",]
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${get_env("TG_REGION", "AWS-REGION")}"
  version = "~> 6.0"
}
EOF
}
