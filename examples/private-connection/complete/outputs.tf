output "iam_role_id" {
  description = "The name of the IAM Role"
  value       = module.iam_role.iam_role_id
}

output "iam_role_arn" {
  description = "The ARN of the IAM Role"
  value       = module.iam_role.iam_role_arn
}

output "enabled_policies" {
  description = "The IAM policies that are enabled for the IAM Role"
  value       = module.iam_role.enabled_policies
}
