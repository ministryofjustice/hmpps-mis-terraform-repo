variable "name" {
  description = "Lambda function name"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}
