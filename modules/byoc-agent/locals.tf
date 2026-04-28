locals {
  create_oidc_provider = var.oidc_provider_url != null

  resolved_oidc_provider_arn = local.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : var.existing_oidc_provider_arn

  resolved_oidc_provider_url = trimsuffix(local.create_oidc_provider ? var.oidc_provider_url : data.aws_iam_openid_connect_provider.existing[0].url, "/")

  oidc_issuer_hostpath = replace(local.resolved_oidc_provider_url, "https://", "")

  tenant_policy_name = coalesce(var.tenant_policy_name, "${var.tenant_role_name}-policy")
  admin_policy_name  = coalesce(var.admin_policy_name, "${var.admin_role_name}-policy")
}
