# Ververica Cloud BYOC Cluster

Provisions the AWS reference infrastructure required to install the
[Ververica Cloud](https://ververica.cloud) Agent in a customer-owned
("Bring Your Own Cloud") account:

- A **VPC** with public and private subnets spread across multiple availability
  zones, an internet gateway, and a NAT gateway so nodes can reach
  `app.ververica.cloud`.
- An **EKS cluster** configured for IRSA (IAM Roles for Service Accounts) via an
  IAM OIDC provider, with the `kube-proxy`, `coredns`, and `vpc-cni` managed
  add-ons pre-installed.
- A **managed node group** sized for the vv-agent and Ververica workspace pods,
  using the instance family and autoscaling parameters recommended by Ververica.

This module is the infrastructure complement to `byoc-agent`: it produces the
cluster, then `byoc-agent` creates the S3 bucket and IAM roles the agent needs
to run on top of it.

> The module wraps two community building blocks:
> [`terraform-aws-modules/vpc/aws ~> 5.0`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
> and
> [`terraform-aws-modules/eks/aws ~> 20.0`](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws).
> These are transitive dependencies any consumer of this module will inherit.

## Usage

```hcl
module "byoc_cluster" {
  source = "ververica/ververica-cloud/aws//modules/byoc-cluster"

  name               = "my-byoc-cluster"
  vpc_cidr           = "10.0.0.0/16"
  kubernetes_version = "1.36"

  # Node sizing (defaults shown — see README for capacity rationale)
  instance_types = ["m6a.2xlarge"]
  desired_size   = 2
  min_size       = 1
  max_size       = 4

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Wiring to byoc-agent

Pass `oidc_provider_arn` from this module to `byoc-agent` as
`existing_oidc_provider_arn` — the OIDC provider is already created by the
cluster and should not be duplicated:

```hcl
module "byoc_agent" {
  source = "ververica/ververica-cloud/aws//modules/byoc-agent"

  bucket_name                = "my-vvc-agent-bucket"
  existing_oidc_provider_arn = module.byoc_cluster.oidc_provider_arn

  admin_role_subject_claims = [
    "system:serviceaccount:ververica:pyxis-admin",
  ]
}
```

See `examples/byoc-cluster/complete/` for a full end-to-end configuration.

## Extending this module

The module exposes the cluster and node security group IDs as outputs so you
can attach your own rules without modifying the module:

```hcl
# Allow an internal load balancer subnet to reach a workload port on the nodes
resource "aws_vpc_security_group_ingress_rule" "internal_lb" {
  security_group_id = module.byoc_cluster.node_security_group_id
  cidr_ipv4         = "10.1.0.0/24"
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"
}
```

Other common extension points:

- `additional_security_group_ids` — attach pre-existing security groups to the
  worker nodes (e.g. to allow access from an RDS or MSK instance).
- `public_subnet_ids` / `private_subnet_ids` outputs — use these to place other
  resources (load balancers, bastion hosts) in the same VPC.
- `cluster_oidc_issuer_url` / `oidc_provider_arn` — pass to `byoc-agent` or
  any other IRSA-enabled module.

## Granting IAM principals cluster access

The cluster uses `authentication_mode = "API_AND_CONFIG_MAP"`. Grant IAM principals
access by adding `aws_eks_access_entry` resources (see below) — this is the
recommended approach. `enable_cluster_creator_admin_permissions` defaults to `false`,
matching the upstream `terraform-aws-modules/eks/aws` module, so the identity that
runs `terraform apply` does **not** receive cluster-admin automatically. Set it to
`true` if you want the applying identity granted cluster-admin without a separate
access entry.

Additional IAM roles or users are granted by adding standalone
`aws_eks_access_entry` + `aws_eks_access_policy_association` resources in your
root module, pointing at the cluster the module creates. Because the cluster's
`authentication_mode` is `API_AND_CONFIG_MAP`, the EKS API accepts these resources
without any `kubernetes` or `helm` provider — the AWS provider is sufficient.

```hcl
resource "aws_eks_access_entry" "ci" {
  cluster_name  = module.byoc_cluster.cluster_name
  principal_arn = "arn:aws:iam::123456789012:role/my-ci-role"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "ci" {
  cluster_name  = module.byoc_cluster.cluster_name
  principal_arn = "arn:aws:iam::123456789012:role/my-ci-role"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.ci]
}
```

Swap `AmazonEKSClusterAdminPolicy` for `AmazonEKSViewPolicy` (or another managed
EKS policy) to grant a narrower permission set. Duplicate the pair for each
additional principal — each `aws_eks_access_entry` / `aws_eks_access_policy_association`
is independent and can be removed individually without touching the cluster or
other entries.

See `examples/byoc-cluster/complete/` for a full runnable configuration.

## Node sizing and capacity rationale

| Parameter | Default | Rationale |
|---|---|---|
| `instance_types` | `["m6a.2xlarge"]` | 8 vCPU / 32 GiB — fits 2 workspace pods (3 vCPU + 18 GiB each) plus vv-agent (2 vCPU + 4 GiB) |
| `desired_size` | `2` | Minimum HA: one node per AZ for pod rescheduling |
| `disk_size` | `50` | 50 GiB accommodates workspace pod ephemeral storage |

Root volumes are always **gp3** and encrypted (`encrypted = true`). There is no `gp2` option; gp3 delivers higher baseline throughput at no extra cost and avoids accumulating storage-type technical debt.

Graviton (arm64) instance types are supported. When using them, set `ami_type` to an arm64 AMI (e.g. `AL2023_ARM_64_STANDARD`); otherwise nodes will fail to join the cluster.

### Production recommendation: separate system and workload node groups

The module ships a single `default` node group for minimum-apply simplicity. For production deployments, consider extending the module with two separate groups:

- **System group** — small on-demand instances (e.g. 2 × m6a.xlarge) dedicated to cluster add-ons and vv-agent control components (~2 vCPU / 4 GiB footprint). Apply the label `node-role: system` and a `CriticalAddonsOnly` taint to keep Flink workload pods off these nodes.
- **Workload group** — larger instances (e.g. m6a.2xlarge or larger) scaled by Cluster Autoscaler or Karpenter, carrying the label `node-role: workload`. Ververica workspace pods (3 vCPU / 18 GiB each) schedule here via matching `nodeSelector` / tolerations configured in the vv-agent Helm chart or workspace templates.

This separation isolates bursty Flink workloads from control-plane components and lets each tier scale independently. Implement it by adding a second entry to `eks_managed_node_groups` in a wrapper module or in-repository Terraform — no changes to this module are required.

## Kubernetes version

The default version is **1.36**. Minimum supported version is **1.28** (the access-entry
floor); this is enforced by a `validation` block on the `kubernetes_version` variable.

EKS access entries (`authentication_mode = "API_AND_CONFIG_MAP"`) are used
instead of the legacy aws-auth ConfigMap approach. No `kubernetes` or `helm`
provider is needed to configure cluster access.

## OIDC provider thumbprint

The IAM OIDC provider's root-CA thumbprint is computed dynamically by the
upstream EKS module (from the cluster's TLS certificate) — it is never pinned in
this module. If AWS rotates the OIDC endpoint's root CA, a `terraform apply`
reconciles the thumbprint automatically; you do not maintain a thumbprint value
by hand.

## Autoscaling

The module exposes `min_size`, `max_size`, and `desired_size` for the managed
node group. This enables manual scaling and is compatible with
[Cluster Autoscaler](https://github.com/kubernetes/autoscaler) and
[Karpenter](https://karpenter.sh/) — both run *inside* the cluster as user-applied
add-ons (install them after the cluster is created; they are not provisioned by
this module).

## Production hardening

> **WARNING — `public_access_cidrs` defaults to `["0.0.0.0/0"]`.**
>
> This makes the EKS API server reachable from the public internet, which is
> convenient for a first apply from a developer workstation but is **not
> acceptable in production**. Before promoting this configuration:
>
> 1. Set `public_access_cidrs` to your corporate egress IP range(s), OR
> 2. Set `cluster_endpoint_public_access = false` and connect only from within
>    the VPC or via a VPN.

> **NAT gateway** — `single_nat_gateway = true` by default to minimise cost in
> reference deployments. For production HA, set `single_nat_gateway = false` to
> provision one NAT gateway per availability zone.

## Cost expectation

Running this module at default settings incurs the following AWS costs
(illustrative, us-east-1 on-demand pricing as of 2025; the example deploys to eu-central-1 by default):

| Resource | Cost |
|---|---|
| EKS control plane | ~$0.10/hour |
| 2 x m6a.2xlarge nodes | ~$0.34/hour each |
| NAT gateway | ~$0.045/hour + $0.045/GB data |

**Always run `terraform destroy` when the cluster is no longer needed.**

## Transitive dependencies

This module depends on two community modules that are downloaded automatically:

| Module | Version constraint | Registry |
|---|---|---|
| `terraform-aws-modules/vpc/aws` | `~> 5.0` | [link](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) |
| `terraform-aws-modules/eks/aws` | `~> 20.0` | [link](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws) |

Treat major-version upgrades of either community module as a separate, deliberate
change — the variable/output surface can change across majors.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | List of additional security group IDs to attach to the worker nodes. Use this to allow inbound traffic from other resources in your account. | `list(string)` | `[]` | no |
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | AMI type for the managed node group (e.g. AL2023\_x86\_64\_STANDARD, AL2023\_ARM\_64\_STANDARD, BOTTLEROCKET\_x86\_64). Leave null to use the EKS module default (x86\_64 AL2023). Set an arm64 type here when instance\_types are Graviton (m*g). | `string` | `null` | no |
| <a name="input_availability_zone_count"></a> [availability\_zone\_count](#input\_availability\_zone\_count) | Number of availability zones to spread subnets across. The module queries the region for available AZs and takes the first N. | `number` | `3` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Enable private access to the EKS API server endpoint from within the VPC. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Enable public access to the EKS API server endpoint. | `bool` | `true` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Desired number of worker nodes in the managed node group. | `number` | `2` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Root EBS volume size in GiB for each worker node. The root volume is always gp3 and encrypted. Minimum 50 GiB recommended for workspace pod ephemeral storage. | `number` | `50` | no |
| <a name="input_enable_cluster_creator_admin_permissions"></a> [enable\_cluster\_creator\_admin\_permissions](#input\_enable\_cluster\_creator\_admin\_permissions) | Grant the identity that runs terraform apply cluster-admin via an access entry. Defaults to false to match the upstream terraform-aws-modules/eks/aws module; grant access explicitly with aws\_eks\_access\_entry resources (see the complete example). Set true to have the applying identity granted cluster-admin automatically. | `bool` | `false` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | EC2 instance types for the managed node group.<br>Recommendation: use x86\_64 m5/m6 families (e.g. m5.xlarge, m6a.2xlarge) for the<br>reference setup — the default (m6a.2xlarge) provides 8 vCPU / 32 GiB, sufficient for<br>2 workspace pods (3 vCPU + 18 GiB each) plus the vv-agent overhead (2 vCPU + 4 GiB).<br>arm64/Graviton types (e.g. m6g, m7g) are supported but require also setting ami\_type<br>to an arm64 AMI (e.g. AL2023\_ARM\_64\_STANDARD); otherwise nodes will not join the cluster. | `list(string)` | <pre>[<br>  "m6a.2xlarge"<br>]</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the EKS cluster. Defaults to 1.36. Must be >= 1.28 (required for EKS access entries). | `string` | `"1.36"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of worker nodes in the managed node group. | `number` | `4` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of worker nodes in the managed node group. | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Name used as a prefix for all resources created by this module (VPC, EKS cluster, etc.). | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | CIDR blocks for private subnets. Must have one entry per availability zone used. Leave empty to auto-compute /24 slices from vpc\_cidr. | `list(string)` | `[]` | no |
| <a name="input_public_access_cidrs"></a> [public\_access\_cidrs](#input\_public\_access\_cidrs) | CIDR blocks allowed to reach the EKS public API server endpoint.<br>WARNING: The default value 0.0.0.0/0 is convenient for reference deployments but<br>exposes the API server to the public internet. Restrict this to your corporate<br>egress IPs (or disable public access entirely) before using this module in production. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for public subnets. Must have one entry per availability zone used. Leave empty to auto-compute /24 slices from vpc\_cidr. | `list(string)` | `[]` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Provision a single shared NAT gateway instead of one per availability zone. Reduces cost for non-production use; set to false for production HA. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources that support tagging. | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC. Must be /16 when relying on auto-computed subnets; pass explicit subnet CIDR lists for other VPC sizes. | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64-encoded certificate authority data for the EKS cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for the EKS Kubernetes API server. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster. |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | OIDC issuer URL for the EKS cluster. Pass to byoc-agent as oidc\_provider\_url when creating a new OIDC provider. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID of the EKS cluster security group (attached to the control plane ENIs). |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | ID of the shared security group attached to all managed node group worker nodes. Attach additional aws\_vpc\_security\_group\_ingress\_rule / aws\_security\_group\_rule resources to this ID to extend ingress. |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the IAM OIDC provider created for the cluster. Pass to byoc-agent as existing\_oidc\_provider\_arn to reuse it. |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets. Worker nodes are placed here. |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets. NAT gateway elastic IPs egress from here. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC created for the cluster. |
<!-- END_TF_DOCS -->
