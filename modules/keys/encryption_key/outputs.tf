output "kms_arn" {
  value = aws_kms_key.kms.arn
}

output "key_id" {
  value = aws_kms_key.kms.key_id
}

