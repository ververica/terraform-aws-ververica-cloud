# Ververica Cloud AWS Terraform Modules

A collection of Terraform modules that provision the AWS-side resources required to
integrate with [Ververica Cloud](https://ververica.cloud).

## Modules

| Module | Description |
|--------|-------------|
| [`private-connection`](./modules/private-connection) | Creates VPC endpoint services and an IAM role so Ververica Cloud can reach resources (RDS, MSK, ElastiCache, …) running in your VPC. |
| [`vpc-endpoint-service`](./modules/vpc-endpoint-service) | Lower-level building block used by `private-connection` to expose a single service via an NLB-fronted VPC endpoint service. |
| [`byoc-agent`](./modules/byoc-agent) | Provisions the S3 bucket, IAM roles, and OIDC trust required by the Ververica Agent in a customer-owned ("Bring Your Own Cloud") AWS account. |

## Usage

### `private-connection`

```hcl
module "private_connection" {
  source                       = "ververica/ververica-cloud/aws//modules/private-connection"

  role_name                    = "VervericaCloudIAMRole"
  ververica_cloud_workspace_id = "my-workspace-id"
  enable_elasticache           = true
  endpoint_services = {
    redis = {
      vpc_id                     = "vpc-1234567890abcdefg"
      create_security_group_rule = true
      security_group_id          = "sg-1234567890abcdefg"
      port                       = 6379
      nodes = [
        # To get the ip you can use something like: dig +short <dns_endpoint>
        {
          ip_address   = "172.31.40.27"
          dns_endpoint = "demo-cluster-1-0001-001.abcdef.0001.euc1.cache.amazonaws.com"
          subnet_id    = "subnet-1234567890abcdefg"
        },
        {
          ip_address   = "172.31.11.25"
          dns_endpoint = "demo-cluster-1-0002-001.abcdef.0001.euc1.cache.amazonaws.com"
          subnet_id    = "subnet-1234567890abcdefg"
        }
      ]
      tags = {
        Description = "Used for Ververica Cloud"
      }
    }
  }
}
```

### `byoc-agent`

```hcl
data "aws_eks_cluster" "this" {
  name = "my-eks-cluster"
}

module "byoc_agent" {
  source = "ververica/ververica-cloud/aws//modules/byoc-agent"

  bucket_name       = "my-vvc-agent-bucket"
  oidc_provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  admin_role_subject_claims = [
    "system:serviceaccount:ververica:ververica-agent",
  ]

  tags = {
    Environment = "production"
  }
}
```

See [`modules/byoc-agent/README.md`](./modules/byoc-agent/README.md) for full input/output documentation and the [`examples/byoc-agent`](./examples/byoc-agent) directory for runnable examples.
