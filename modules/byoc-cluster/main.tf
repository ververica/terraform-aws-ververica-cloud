# ---------------------------------------------------------------------------
# VPC — public + private subnets with EKS discovery tags
# ---------------------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnet_cidrs
  public_subnets  = local.public_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  # EKS subnet autodiscovery tags
  public_subnet_tags = {
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# EKS cluster — IRSA, add-ons, managed node group
# ---------------------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Endpoint access — both enabled by default; see README for production hardening
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.public_access_cidrs

  # Authentication — access entries require no kubernetes/helm provider
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # OIDC / IRSA — required for byoc-agent and any IRSA-dependent workload
  enable_irsa = true

  # EKS managed add-ons
  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Security group rules required for Ververica Platform that the EKS module's
  # recommended node rules do not cover.
  node_security_group_additional_rules = {
    ingress_self_vvp_nginx_http = {
      description = "Node to node HTTP for vvp-nginx"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      self        = true
    }
    ingress_cluster_webhook = {
      description                   = "Cluster API to node webhook"
      protocol                      = "tcp"
      from_port                     = 9666
      to_port                       = 9666
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  # Managed node group
  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types
      ami_type       = var.ami_type
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size

      # block_device_mappings is required to set disk size when
      # use_custom_launch_template = true (the EKS module default in v20).
      # disk_size is a no-op in that mode; the root volume must be configured here.
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.disk_size
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      # Place nodes in private subnets
      subnet_ids = module.vpc.private_subnets

      # Additional security groups for extensibility
      vpc_security_group_ids = var.additional_security_group_ids
    }
  }

  tags = var.tags
}
