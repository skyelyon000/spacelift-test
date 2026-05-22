output "bucket_name" {
  description = "Name of the playground S3 bucket"
  value       = aws_s3_bucket.playground.bucket
}

output "bucket_arn" {
  description = "ARN of the playground S3 bucket"
  value       = aws_s3_bucket.playground.arn
}

output "ssm_parameter_name" {
  description = "Name of the playground SSM parameter"
  value       = aws_ssm_parameter.playground.name
}

output "iam_role_arn" {
  description = "ARN of the playground IAM role (if created)"
  value       = var.create_iam_role ? aws_iam_role.playground[0].arn : null
}

output "name_prefix" {
  description = "Shared name prefix used across resources"
  value       = local.name_prefix
}
