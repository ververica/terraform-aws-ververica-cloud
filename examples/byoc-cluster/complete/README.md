# byoc-cluster — complete example

End-to-end BYOC setup: provisions a VPC and EKS cluster with `byoc-cluster`,
grants an IAM role cluster access, and wires the cluster's OIDC provider into
`byoc-agent` to create the S3 bucket and IAM roles the Ververica Agent needs.

## Architecture

```
byoc-cluster  ──────────────────────────────────────────────────
  VPC (public + private subnets, NAT gateway)
  EKS cluster (OIDC/IRSA, add-ons, managed node group)
        │
        ├─ aws_eks_access_entry        → grants an IAM role cluster-admin
        │
        │ oidc_provider_arn  (existing, not duplicated)
        │
byoc-agent  ────────────────────────────────────────────────────
  S3 bucket (agent storage)
  IAM admin role  (OIDC web identity → service account trust)
  IAM tenant role (S3 access, assumed by admin role)
```

## Usage

Most values are inlined in the configuration. Two inputs must vary per
deployment; `region` is optional:

| Variable | Required | Description |
|---|---|---|
| `access_role_arn` | yes | IAM role ARN to grant cluster-admin (e.g. an SSO permission-set or CI role) |
| `agent_bucket_name` | yes | Globally unique S3 bucket name for the agent |
| `region` | no | AWS region (default: `eu-central-1`) |
| `agent_namespace` | no | Namespace the agent installs into (default: `ververica`) |
| `agent_service_account` | no | Agent admin service account (default: `pyxis-admin`) |

```bash
terraform init
terraform apply \
  -var="access_role_arn=arn:aws:iam::123456789012:role/my-team-role" \
  -var="agent_bucket_name=my-vvc-agent-bucket"
```

After apply, the role in
 `access_role_arn` has cluster-admin. Point `kubectl` at the cluster with:

```bash
aws eks update-kubeconfig --name byoc-cluster --region <your-region>
```

Then install the Ververica Agent helm chart using the output values.

## Granting more principals

Access is managed with standalone resources in this root module, so you control
it without reading the module internals. Copy the `aws_eks_access_entry` +
`aws_eks_access_policy_association` pair for each additional role or user, and
swap `AmazonEKSClusterAdminPolicy` for `AmazonEKSViewPolicy` to grant read-only
access instead.

## What this example creates

- VPC (`10.0.0.0/16`) with public and private subnets across 3 AZs, NAT gateway.
- EKS cluster (`byoc-cluster`, Kubernetes 1.36) with OIDC/IRSA, kube-proxy,
  coredns, and vpc-cni add-ons.
- Managed node group: 2 x m6a.2xlarge (min 1 / max 4), gp3 encrypted root volume.
- An EKS access entry granting `access_role_arn` cluster-admin.
- Agent S3 bucket with default security hardening (encryption, TLS-only, public
  access block), plus admin and tenant IAM roles with OIDC trust locked to the
  agent service account (`system:serviceaccount:ververica:pyxis-admin`).

## Cost note

Running this example at default sizing incurs real AWS costs:

| Resource | Approximate cost (us-east-1) |
|---|---|
| EKS control plane | ~$0.10/hour |
| 2 x m6a.2xlarge nodes | ~$0.34/hour each |
| NAT gateway | ~$0.045/hour + data |
| S3 bucket | pay-per-use |

Destroy when done: `terraform destroy`.
