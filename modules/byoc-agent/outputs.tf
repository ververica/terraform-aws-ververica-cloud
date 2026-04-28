output "bucket_name" {
  description = "Name of the agent S3 bucket."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the agent S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID of the agent S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "tenant_role_arn" {
  description = "ARN of the tenant IAM role."
  value       = aws_iam_role.tenant.arn
}

output "tenant_role_name" {
  description = "Name of the tenant IAM role."
  value       = aws_iam_role.tenant.name
}

output "admin_role_arn" {
  description = "ARN of the admin IAM role."
  value       = aws_iam_role.admin.arn
}

output "admin_role_name" {
  description = "Name of the admin IAM role."
  value       = aws_iam_role.admin.name
}

output "tenant_policy_arn" {
  description = "ARN of the managed policy attached to the tenant role."
  value       = aws_iam_policy.tenant.arn
}

output "admin_policy_arn" {
  description = "ARN of the managed policy attached to the admin role."
  value       = aws_iam_policy.admin.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider (created by this module or supplied as an existing one)."
  value       = local.resolved_oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider used for the admin role's trust policy."
  value       = local.resolved_oidc_provider_url
}

output "oidc_provider_created" {
  description = "Whether the OIDC provider was created by this module."
  value       = local.create_oidc_provider
}
