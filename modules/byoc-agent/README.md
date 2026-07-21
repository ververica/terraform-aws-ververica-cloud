# Ververica Cloud BYOC Agent

Provisions the AWS resources required by the [Ververica Cloud](https://ververica.cloud)
Agent in a customer-owned ("Bring Your Own Cloud") account:

- An S3 bucket with CORS rules suitable for the Ververica web app, plus opinionated
  defaults for encryption, public-access block, and TLS-only access.
- A **tenant** IAM role with read/write/list access to that bucket.
- An **admin** IAM role assumed via OIDC web identity from an EKS cluster, allowed to
  assume the tenant role.
- An IAM OIDC provider — created by the module, or referenced by ARN if you already
  have one.

This module replaces the legacy CloudFormation template that customers used to deploy
in their accounts.

## Usage

### Create the OIDC provider

```hcl
data "aws_eks_cluster" "this" {
  name = "my-eks-cluster"
}

module "byoc_agent" {
  source = "ververica/ververica-cloud/aws//modules/byoc-agent"

  bucket_name       = "my-vvc-agent-bucket"
  oidc_provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  # Recommended: lock the admin role's trust policy to a specific service account.
  admin_role_subject_claims = [
    "system:serviceaccount:ververica:pyxis-admin",
  ]

  tags = {
    Environment = "production"
  }
}
```

### Reuse an existing OIDC provider

```hcl
module "byoc_agent" {
  source = "ververica/ververica-cloud/aws//modules/byoc-agent"

  bucket_name                = "my-vvc-agent-bucket"
  existing_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/EXAMPLE"

  admin_role_subject_claims = [
    "system:serviceaccount:ververica:pyxis-admin",
  ]
}
```

Exactly one of `oidc_provider_url` and `existing_oidc_provider_arn` must be set.

## Extensibility

Common extension points:

- **CORS** — `cors_allowed_origins`, `cors_allowed_methods`, `cors_allowed_headers`,
  `cors_exposed_headers`, `cors_max_age_seconds`.
- **Encryption** — `bucket_encryption_enabled` (default `true`, SSE-S3) plus
  `bucket_kms_key_arn` to switch to SSE-KMS.
- **OIDC trust restriction** — `admin_role_subject_claims` and
  `admin_role_audience_claims` add `sub` / `aud` conditions to the admin role's
  trust policy. Strongly recommended in production.
- **Extra managed policies** — `additional_tenant_role_policy_arns` and
  `additional_admin_role_policy_arns` attach existing managed policies to the roles.

## Security notes

- The legacy CloudFormation template did not restrict `sub`/`aud` on the admin role's
  trust policy. The module preserves that behaviour by default but exposes
  `admin_role_subject_claims` to lock the role down to a specific Kubernetes service
  account. **Set this variable in production.**
- `bucket_block_public_access`, `bucket_encryption_enabled` and `bucket_enforce_tls`
  default to `true`.
- The TLS-only bucket policy is created after the public access block to avoid the
  brief window in which the bucket would otherwise be publicly writable.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.tenant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.tenant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.admin_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tenant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tenant_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_openid_connect_provider.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.admin_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.bucket_tls_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tenant_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_admin_role_policy_arns"></a> [additional\_admin\_role\_policy\_arns](#input\_additional\_admin\_role\_policy\_arns) | Extra managed policy ARNs to attach to the admin role. | `list(string)` | `[]` | no |
| <a name="input_additional_tenant_role_policy_arns"></a> [additional\_tenant\_role\_policy\_arns](#input\_additional\_tenant\_role\_policy\_arns) | Extra managed policy ARNs to attach to the tenant role. | `list(string)` | `[]` | no |
| <a name="input_admin_policy_name"></a> [admin\_policy\_name](#input\_admin\_policy\_name) | Name of the managed policy attached to the admin role. Defaults to <admin\_role\_name>-policy. | `string` | `null` | no |
| <a name="input_admin_role_audience_claims"></a> [admin\_role\_audience\_claims](#input\_admin\_role\_audience\_claims) | OIDC `aud` claim values required when assuming the admin role. Set to an empty list to skip the `aud` condition. | `list(string)` | <pre>[<br>  "sts.amazonaws.com"<br>]</pre> | no |
| <a name="input_admin_role_name"></a> [admin\_role\_name](#input\_admin\_role\_name) | Name of the IAM role assumed via OIDC web identity that can in turn assume the tenant role. | `string` | `"VVCAdminRole"` | no |
| <a name="input_admin_role_subject_claims"></a> [admin\_role\_subject\_claims](#input\_admin\_role\_subject\_claims) | Optional list of OIDC `sub` claim values allowed to assume the admin role (e.g. system:serviceaccount:<ns>:<sa>). Empty list means no `sub` restriction — strongly discouraged in production. | `list(string)` | `[]` | no |
| <a name="input_bucket_block_public_access"></a> [bucket\_block\_public\_access](#input\_bucket\_block\_public\_access) | Block all public access on the agent bucket. Recommended. | `bool` | `true` | no |
| <a name="input_bucket_encryption_enabled"></a> [bucket\_encryption\_enabled](#input\_bucket\_encryption\_enabled) | Enable server-side encryption (SSE-S3 by default) on the agent bucket. | `bool` | `true` | no |
| <a name="input_bucket_enforce_tls"></a> [bucket\_enforce\_tls](#input\_bucket\_enforce\_tls) | Attach a bucket policy that denies any non-TLS request. | `bool` | `true` | no |
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy) | Whether to allow Terraform to destroy the bucket even if it contains objects. Useful in non-production accounts. | `bool` | `false` | no |
| <a name="input_bucket_kms_key_arn"></a> [bucket\_kms\_key\_arn](#input\_bucket\_kms\_key\_arn) | Optional KMS key ARN for SSE-KMS. If null and bucket\_encryption\_enabled is true, SSE-S3 (AES256) is used. | `string` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket used by the Ververica Agent. | `string` | n/a | yes |
| <a name="input_bucket_versioning_enabled"></a> [bucket\_versioning\_enabled](#input\_bucket\_versioning\_enabled) | Enable S3 bucket versioning. | `bool` | `false` | no |
| <a name="input_cors_allowed_headers"></a> [cors\_allowed\_headers](#input\_cors\_allowed\_headers) | CORS allowed headers for the agent S3 bucket. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_cors_allowed_methods"></a> [cors\_allowed\_methods](#input\_cors\_allowed\_methods) | CORS allowed methods for the agent S3 bucket. | `list(string)` | <pre>[<br>  "GET",<br>  "POST",<br>  "PUT",<br>  "DELETE",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | CORS allowed origins for the agent S3 bucket. | `list(string)` | <pre>[<br>  "https://app.ververica.cloud"<br>]</pre> | no |
| <a name="input_cors_exposed_headers"></a> [cors\_exposed\_headers](#input\_cors\_exposed\_headers) | CORS exposed headers for the agent S3 bucket. | `list(string)` | <pre>[<br>  "ETag"<br>]</pre> | no |
| <a name="input_cors_max_age_seconds"></a> [cors\_max\_age\_seconds](#input\_cors\_max\_age\_seconds) | CORS max age (in seconds) for the agent S3 bucket. | `number` | `3000` | no |
| <a name="input_existing_oidc_provider_arn"></a> [existing\_oidc\_provider\_arn](#input\_existing\_oidc\_provider\_arn) | ARN of an existing IAM OIDC provider to reuse. Mutually exclusive with oidc\_provider\_url. | `string` | `null` | no |
| <a name="input_oidc_client_id_list"></a> [oidc\_client\_id\_list](#input\_oidc\_client\_id\_list) | Client IDs (audiences) for the OIDC provider when it is created by this module. | `list(string)` | <pre>[<br>  "sts.amazonaws.com"<br>]</pre> | no |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL of the EKS cluster OIDC issuer. Set this to have the module create the IAM OIDC provider. Mutually exclusive with existing\_oidc\_provider\_arn. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources that support tagging. | `map(string)` | `{}` | no |
| <a name="input_tenant_policy_name"></a> [tenant\_policy\_name](#input\_tenant\_policy\_name) | Name of the managed policy attached to the tenant role. Defaults to <tenant\_role\_name>-policy. | `string` | `null` | no |
| <a name="input_tenant_role_name"></a> [tenant\_role\_name](#input\_tenant\_role\_name) | Name of the IAM role with permissions on the agent's S3 bucket. | `string` | `"VVCTenantRole"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_policy_arn"></a> [admin\_policy\_arn](#output\_admin\_policy\_arn) | ARN of the managed policy attached to the admin role. |
| <a name="output_admin_role_arn"></a> [admin\_role\_arn](#output\_admin\_role\_arn) | ARN of the admin IAM role. |
| <a name="output_admin_role_name"></a> [admin\_role\_name](#output\_admin\_role\_name) | Name of the admin IAM role. |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the agent S3 bucket. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID of the agent S3 bucket. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the agent S3 bucket. |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the OIDC provider (created by this module or supplied as an existing one). |
| <a name="output_oidc_provider_created"></a> [oidc\_provider\_created](#output\_oidc\_provider\_created) | Whether the OIDC provider was created by this module. |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | URL of the OIDC provider used for the admin role's trust policy. |
| <a name="output_tenant_policy_arn"></a> [tenant\_policy\_arn](#output\_tenant\_policy\_arn) | ARN of the managed policy attached to the tenant role. |
| <a name="output_tenant_role_arn"></a> [tenant\_role\_arn](#output\_tenant\_role\_arn) | ARN of the tenant IAM role. |
| <a name="output_tenant_role_name"></a> [tenant\_role\_name](#output\_tenant\_role\_name) | Name of the tenant IAM role. |
<!-- END_TF_DOCS -->
