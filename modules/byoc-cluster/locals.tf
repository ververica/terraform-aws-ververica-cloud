data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Slice AZs to the requested count
  azs = slice(data.aws_availability_zones.available.names, 0, var.availability_zone_count)

  # Auto-compute /24 CIDR slices if none provided.
  # Private subnets use the first N /24 blocks; public subnets the next N.
  # Consumers can override both lists explicitly.
  default_private_subnet_cidrs = [
    for i in range(var.availability_zone_count) :
    cidrsubnet(var.vpc_cidr, 8, i)
  ]
  default_public_subnet_cidrs = [
    for i in range(var.availability_zone_count) :
    cidrsubnet(var.vpc_cidr, 8, i + var.availability_zone_count)
  ]

  private_subnet_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : local.default_private_subnet_cidrs
  public_subnet_cidrs  = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : local.default_public_subnet_cidrs
}
