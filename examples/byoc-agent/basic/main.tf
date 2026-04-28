terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

module "vvc_byoc" {
  source = "../../../modules/byoc-agent"

  bucket_name       = var.bucket_name
  oidc_provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  admin_role_subject_claims = [
    "system:serviceaccount:${var.agent_namespace}:${var.agent_service_account}",
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Module      = "byoc-agent"
  }
}
