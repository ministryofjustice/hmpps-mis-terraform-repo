terragrunt = {

  include {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = [
      "../common",
      "../security-groups",
      "../iam",
      "../s3buckets",
    ]
  }
}
