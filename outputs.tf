output "kms_key_arn" {
  description = "The ARN for the AWS KMS Custom Master Key"
  value       = aws_kms_key.a.arn
}

output "iam_role_arn" {
  description = "The ARN for the AWS IAM role used for export"
  value       = aws_iam_role.main.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket used for export destination"
  value       = aws_s3_bucket.mail_export.bucket
}