variable "region" {
  description = "AWS region."
  type        = string
}

variable "bucket_name" {
  description = "Name of the agent S3 bucket."
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster whose OIDC issuer the admin role should trust."
  type        = string
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