# Cluster outputs
output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.byoc_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.byoc_cluster.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the cluster."
  value       = module.byoc_cluster.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN (shared between byoc-cluster and byoc-agent)."
  value       = module.byoc_cluster.oidc_provider_arn
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.byoc_cluster.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.byoc_cluster.private_subnet_ids
}

output "node_security_group_id" {
  description = "Node security group ID."
  value       = module.byoc_cluster.node_security_group_id
}

# Agent outputs
output "agent_bucket_name" {
  description = "Name of the agent S3 bucket."
  value       = module.byoc_agent.bucket_name
}

output "agent_admin_role_arn" {
  description = "ARN of the byoc-agent admin IAM role."
  value       = module.byoc_agent.admin_role_arn
}

output "agent_tenant_role_arn" {
  description = "ARN of the byoc-agent tenant IAM role."
  value       = module.byoc_agent.tenant_role_arn
}
