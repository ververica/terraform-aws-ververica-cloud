variable "bucket_name" {
  description = "Name of the S3 bucket used by the Ververica Agent."
  type        = string
}

variable "tenant_role_name" {
  description = "Name of the IAM role with permissions on the agent's S3 bucket."
  type        = string
  default     = "VVCTenantRole"
}

variable "admin_role_name" {
  description = "Name of the IAM role assumed via OIDC web identity that can in turn assume the tenant role."
  type        = string
  default     = "VVCAdminRole"
}

variable "tenant_policy_name" {
  description = "Name of the managed policy attached to the tenant role. Defaults to <tenant_role_name>-policy."
  type        = string
  default     = null
}

variable "admin_policy_name" {
  description = "Name of the managed policy attached to the admin role. Defaults to <admin_role_name>-policy."
  type        = string
  default     = null
}

variable "oidc_provider_url" {
  description = "URL of the EKS cluster OIDC issuer. Set this to have the module create the IAM OIDC provider. Mutually exclusive with existing_oidc_provider_arn."
  type        = string
  default     = null

  validation {
    condition     = var.oidc_provider_url == null || can(regex("^https://", var.oidc_provider_url))
    error_message = "oidc_provider_url must be an https:// URL or null."
  }
}

variable "existing_oidc_provider_arn" {
  description = "ARN of an existing IAM OIDC provider to reuse. Mutually exclusive with oidc_provider_url."
  type        = string
  default     = null

  validation {
    condition     = var.existing_oidc_provider_arn == null || can(regex("^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:oidc-provider/", var.existing_oidc_provider_arn))
    error_message = "existing_oidc_provider_arn must be a valid IAM OIDC provider ARN."
  }
}

variable "oidc_client_id_list" {
  description = "Client IDs (audiences) for the OIDC provider when it is created by this module."
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "admin_role_subject_claims" {
  description = "Optional list of OIDC `sub` claim values allowed to assume the admin role (e.g. system:serviceaccount:<ns>:<sa>). Empty list means no `sub` restriction — strongly discouraged in production."
  type        = list(string)
  default     = []
}

variable "admin_role_audience_claims" {
  description = "OIDC `aud` claim values required when assuming the admin role. Set to an empty list to skip the `aud` condition."
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins for the agent S3 bucket."
  type        = list(string)
  default     = ["https://app.ververica.cloud"]
}

variable "cors_allowed_methods" {
  description = "CORS allowed methods for the agent S3 bucket."
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "HEAD"]
}

variable "cors_allowed_headers" {
  description = "CORS allowed headers for the agent S3 bucket."
  type        = list(string)
  default     = ["*"]
}

variable "cors_exposed_headers" {
  description = "CORS exposed headers for the agent S3 bucket."
  type        = list(string)
  default     = ["ETag"]
}

variable "cors_max_age_seconds" {
  description = "CORS max age (in seconds) for the agent S3 bucket."
  type        = number
  default     = 3000
}

variable "bucket_force_destroy" {
  description = "Whether to allow Terraform to destroy the bucket even if it contains objects. Useful in non-production accounts."
  type        = bool
  default     = false
}

variable "bucket_versioning_enabled" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = false
}

variable "bucket_encryption_enabled" {
  description = "Enable server-side encryption (SSE-S3 by default) on the agent bucket."
  type        = bool
  default     = true
}

variable "bucket_kms_key_arn" {
  description = "Optional KMS key ARN for SSE-KMS. If null and bucket_encryption_enabled is true, SSE-S3 (AES256) is used."
  type        = string
  default     = null
}

variable "bucket_block_public_access" {
  description = "Block all public access on the agent bucket. Recommended."
  type        = bool
  default     = true
}

variable "bucket_enforce_tls" {
  description = "Attach a bucket policy that denies any non-TLS request."
  type        = bool
  default     = true
}


variable "additional_tenant_role_policy_arns" {
  description = "Extra managed policy ARNs to attach to the tenant role."
  type        = list(string)
  default     = []
}

variable "additional_admin_role_policy_arns" {
  description = "Extra managed policy ARNs to attach to the admin role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all resources that support tagging."
  type        = map(string)
  default     = {}
}
