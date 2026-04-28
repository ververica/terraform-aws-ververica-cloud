variable "region" {
  description = "AWS region."
  type        = string
}

variable "bucket_name" {
  description = "Name of the agent S3 bucket."
  type        = string
}

variable "existing_oidc_provider_arn" {
  description = "ARN of the existing IAM OIDC provider to reuse."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used for SSE-KMS on the bucket and granted to the tenant role."
  type        = string
  default     = null
}

variable "agent_namespace" {
  description = "Kubernetes namespace where the Ververica Agent runs."
  type        = string
  default     = "ververica"
}

variable "agent_service_account" {
  description = "Kubernetes service account name used by the Ververica Agent."
  type        = string
  default     = "ververica-agent"
}