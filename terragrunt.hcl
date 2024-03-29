remote_state {
  backend = "s3"

  config = {
    encrypt = true
    bucket  = "${get_env("TG_REMOTE_STATE_BUCKET", "REMOTE_STATE_BUCKET")}"
    ###key     = "mis/${path_relative_to_include()}/terraform.tfstate"
    key     = "${get_env("TG_ENVIRONMENT_TYPE", "ENVIRONMENT")}/${path_relative_to_include()}/terraform.tfstate"
    region  = "${get_env("TG_REGION", "AWS-REGION")}"
    dynamodb_table = "${get_env("TG_ENVIRONMENT_IDENTIFIER", "ENVIRONMENT_IDENTIFIER")}-lock-table"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = [
      "destroy",
      "plan",
      "import",
      "push",
      "refresh",
      "taint",
      "untaint",
    ]

    arguments = [
      "-var-file=${get_parent_terragrunt_dir()}/env_configs/${get_env("TG_COMMON_DIRECTORY","common")}/common.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/env_configs/${get_env("TG_ENVIRONMENT_NAME", "ENVIRONMENT")}/${get_env("TG_ENVIRONMENT_NAME", "ENVIRONMENT")}.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/env_configs/${get_env("TG_ENVIRONMENT_NAME", "ENVIRONMENT")}/sub-projects/mis.tfvars",
      "-var-file=${get_parent_terragrunt_dir()}/env_configs/${get_env("TG_ENVIRONMENT_NAME", "ENVIRONMENT")}/sub-projects/delius-core.tfvars",
    ]
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${get_env("TG_REGION", "AWS-REGION")}"
  version = "~> 3.0"
}
EOF
}
