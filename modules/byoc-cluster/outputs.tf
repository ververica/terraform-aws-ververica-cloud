# ---------------------------------------------------------------------------
# EKS cluster
# ---------------------------------------------------------------------------

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the EKS cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster. Pass to byoc-agent as oidc_provider_url when creating a new OIDC provider."
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider created for the cluster. Pass to byoc-agent as existing_oidc_provider_arn to reuse it."
  value       = module.eks.oidc_provider_arn
}

# ---------------------------------------------------------------------------
# Security groups
# ---------------------------------------------------------------------------

output "cluster_security_group_id" {
  description = "ID of the EKS cluster security group (attached to the control plane ENIs)."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "ID of the shared security group attached to all managed node group worker nodes. Attach additional aws_vpc_security_group_ingress_rule / aws_security_group_rule resources to this ID to extend ingress."
  value       = module.eks.node_security_group_id
}

# ---------------------------------------------------------------------------
# VPC / networking
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC created for the cluster."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets. Worker nodes are placed here."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets. NAT gateway elastic IPs egress from here."
  value       = module.vpc.public_subnets
}
