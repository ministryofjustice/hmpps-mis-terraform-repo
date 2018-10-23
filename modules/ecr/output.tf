# Alfresco ecr
output "repository_url" {
  value = "${module.ecr.repo_repository_url}"
}

output "repository_arn" {
  value = "${module.ecr.repo_repository_arn}"
}

output "repository_name" {
  value = "${module.ecr.repo_repository_name}"
}
