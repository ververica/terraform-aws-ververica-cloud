# Complete BYOC setup: a VPC and EKS cluster, an IAM access entry granting a
# team/CI role cluster-admin, and the byoc-agent resources wired to the
# cluster's OIDC provider.

module "byoc_cluster" {
  source = "../../../modules/byoc-cluster"

  name               = "byoc-cluster"
  vpc_cidr           = "10.0.0.0/16"
  kubernetes_version = "1.36"

  instance_types = ["m6a.2xlarge"]
  desired_size   = 2
  min_size       = 1
  max_size       = 4

  # Prefer granting cluster access explicitly via aws_eks_access_entry resources
  # (see below) over the implicit creator grant. Kept false so no principal gets
  # cluster-admin merely for running terraform apply.
  enable_cluster_creator_admin_permissions = false

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Grant an existing IAM role cluster-admin by adding an EKS access entry directly.
# Duplicate this pair (with a different name/principal_arn) for each additional
# role or user you want to grant, and swap the policy_arn for a narrower policy
# (e.g. AmazonEKSViewPolicy) as needed.
resource "aws_eks_access_entry" "admin" {
  cluster_name  = module.byoc_cluster.cluster_name
  principal_arn = var.access_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = module.byoc_cluster.cluster_name
  principal_arn = var.access_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

# Wire the cluster's OIDC provider into byoc-agent to create the S3 bucket and
# IAM roles the agent needs. The OIDC provider is already created by the
# cluster; pass its ARN so it is not duplicated.
module "byoc_agent" {
  source = "../../../modules/byoc-agent"

  bucket_name                = var.agent_bucket_name
  existing_oidc_provider_arn = module.byoc_cluster.oidc_provider_arn

  # Scope the admin role's OIDC trust to the agent's service account in the
  # namespace where it will be installed.
  admin_role_subject_claims = [
    "system:serviceaccount:${var.agent_namespace}:${var.agent_service_account}",
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
