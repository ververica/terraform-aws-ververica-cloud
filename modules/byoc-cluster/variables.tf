# ---------------------------------------------------------------------------
# Naming
# ---------------------------------------------------------------------------

variable "name" {
  description = "Name used as a prefix for all resources created by this module (VPC, EKS cluster, etc.)."
  type        = string
}

# ---------------------------------------------------------------------------
# VPC / networking
# ---------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be /16 when relying on auto-computed subnets; pass explicit subnet CIDR lists for other VPC sizes."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition = can(cidrhost(var.vpc_cidr, 0)) && (
      tonumber(split("/", var.vpc_cidr)[1]) == 16 ||
      (length(var.private_subnet_cidrs) > 0 && length(var.public_subnet_cidrs) > 0)
    )
    error_message = "vpc_cidr must be a valid CIDR. If private_subnet_cidrs/public_subnet_cidrs are not provided, vpc_cidr must be /16 (e.g. 10.0.0.0/16) so the module can auto-compute /24 subnets."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets. Must have one entry per availability zone used. Leave empty to auto-compute /24 slices from vpc_cidr."
  type        = list(string)
  default     = []

  validation {
    condition = length(var.private_subnet_cidrs) == 0 || (
      length(var.private_subnet_cidrs) == var.availability_zone_count &&
      alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    )
    error_message = "private_subnet_cidrs must be empty or contain exactly availability_zone_count valid CIDR blocks."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. Must have one entry per availability zone used. Leave empty to auto-compute /24 slices from vpc_cidr."
  type        = list(string)
  default     = []

  validation {
    condition = length(var.public_subnet_cidrs) == 0 || (
      length(var.public_subnet_cidrs) == var.availability_zone_count &&
      alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    )
    error_message = "public_subnet_cidrs must be empty or contain exactly availability_zone_count valid CIDR blocks."
  }
}

variable "availability_zone_count" {
  description = "Number of availability zones to spread subnets across. The module queries the region for available AZs and takes the first N."
  type        = number
  default     = 3

  validation {
    condition     = var.availability_zone_count >= 2 && var.availability_zone_count <= 6
    error_message = "availability_zone_count must be between 2 and 6."
  }
}

variable "single_nat_gateway" {
  description = "Provision a single shared NAT gateway instead of one per availability zone. Reduces cost for non-production use; set to false for production HA."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# EKS cluster
# ---------------------------------------------------------------------------

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster. Defaults to 1.36. Must be >= 1.28 (required for EKS access entries)."
  type        = string
  default     = "1.36"

  validation {
    condition     = can(regex("^1\\.(2[89]|[3-9][0-9])(\\.[0-9]+)?$", var.kubernetes_version))
    error_message = "kubernetes_version must be 1.28 or later in the 1.x line (e.g. \"1.28\", \"1.36\"). EKS access entries require >= 1.28."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API server endpoint."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the EKS API server endpoint from within the VPC."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = <<-EOT
    CIDR blocks allowed to reach the EKS public API server endpoint.
    WARNING: The default value 0.0.0.0/0 is convenient for reference deployments but
    exposes the API server to the public internet. Restrict this to your corporate
    egress IPs (or disable public access entirely) before using this module in production.
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------
# Node group — sizing and autoscaling
# ---------------------------------------------------------------------------

variable "instance_types" {
  description = <<-EOT
    EC2 instance types for the managed node group.
    Recommendation: use x86_64 m5/m6 families (e.g. m5.xlarge, m6a.2xlarge) for the
    reference setup — the default (m6a.2xlarge) provides 8 vCPU / 32 GiB, sufficient for
    2 workspace pods (3 vCPU + 18 GiB each) plus the vv-agent overhead (2 vCPU + 4 GiB).
    arm64/Graviton types (e.g. m6g, m7g) are supported but require also setting ami_type
    to an arm64 AMI (e.g. AL2023_ARM_64_STANDARD); otherwise nodes will not join the cluster.
  EOT
  type        = list(string)
  default     = ["m6a.2xlarge"]
}

variable "desired_size" {
  description = "Desired number of worker nodes in the managed node group."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_size >= var.min_size && var.desired_size <= var.max_size
    error_message = "desired_size must be between min_size and max_size."
  }
}

variable "min_size" {
  description = "Minimum number of worker nodes in the managed node group."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes in the managed node group."
  type        = number
  default     = 4
}

variable "disk_size" {
  description = "Root EBS volume size in GiB for each worker node. The root volume is always gp3 and encrypted. Minimum 50 GiB recommended for workspace pod ephemeral storage."
  type        = number
  default     = 50
}

variable "ami_type" {
  description = "AMI type for the managed node group (e.g. AL2023_x86_64_STANDARD, AL2023_ARM_64_STANDARD, BOTTLEROCKET_x86_64). Leave null to use the EKS module default (x86_64 AL2023). Set an arm64 type here when instance_types are Graviton (m*g)."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Access entries — IAM authentication
# ---------------------------------------------------------------------------

variable "enable_cluster_creator_admin_permissions" {
  description = "Grant the identity that runs terraform apply cluster-admin via an access entry. Defaults to false to match the upstream terraform-aws-modules/eks/aws module; grant access explicitly with aws_eks_access_entry resources (see the complete example). Set true to have the applying identity granted cluster-admin automatically."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Extensibility
# ---------------------------------------------------------------------------

variable "additional_security_group_ids" {
  description = "List of additional security group IDs to attach to the worker nodes. Use this to allow inbound traffic from other resources in your account."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Tagging
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Tags applied to all resources that support tagging."
  type        = map(string)
  default     = {}
}
