## For ease of maintenance outputs are close to resource creation.

locals {
  tags = data.terraform_remote_state.common.outputs.common_tags
}
