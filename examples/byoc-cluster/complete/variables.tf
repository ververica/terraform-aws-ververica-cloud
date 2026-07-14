variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-central-1"
}

variable "access_role_arn" {
  description = "ARN of an existing IAM role to grant cluster-admin access via an EKS access entry (e.g. an SSO permission-set role or a CI role)."
  type        = string
}

variable "agent_bucket_name" {
  description = "Globally unique S3 bucket name for the Ververica Agent."
  type        = string
}
