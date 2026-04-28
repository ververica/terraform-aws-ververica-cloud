output "bucket_name" {
  value = module.vvc_byoc.bucket_name
}

output "tenant_role_arn" {
  value = module.vvc_byoc.tenant_role_arn
}

output "admin_role_arn" {
  value = module.vvc_byoc.admin_role_arn
}

output "oidc_provider_arn" {
  value = module.vvc_byoc.oidc_provider_arn
}
