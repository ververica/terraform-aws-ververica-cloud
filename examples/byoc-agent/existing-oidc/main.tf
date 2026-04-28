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

module "vvc_byoc" {
  source = "../../../modules/byoc-agent"

  bucket_name                = var.bucket_name
  existing_oidc_provider_arn = var.existing_oidc_provider_arn

  admin_role_subject_claims = [
    "system:serviceaccount:${var.agent_namespace}:${var.agent_service_account}",
  ]

  bucket_kms_key_arn = var.kms_key_arn

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
