# Ververica Cloud AWS Terraform Modules

A collection of Terraform modules that provision the AWS resources required to use Ververica Platform services. 

## Usage

| Module | Description |
|--------|-------------|
| [`byoc-cluster`](./modules/byoc-cluster) | Provisions VPC, Subnets, EKS cluster and related resources required by the Ververica Agent in a customer-owned ("Bring Your Own Cloud") AWS account. See [`modules/byoc-cluster/README.md`](./modules/byoc-cluster/README.md) for full input/output documentation and the [`examples/byoc-cluster`](./examples/byoc-cluster) directory for runnable examples. |
| [`byoc-agent`](./modules/byoc-agent) | Provisions the S3 bucket, IAM roles, and OIDC trust required by the Ververica Agent in a customer-owned ("Bring Your Own Cloud") AWS account. See [`modules/byoc-agent/README.md`](./modules/byoc-agent/README.md) for full input/output documentation and the [`examples/byoc-agent`](./examples/byoc-agent) directory for runnable examples. |

## Deprecated
The following modules are currently deprecated.

| Module | Description |
|--------|-------------|
| [`private-connection`](./modules/private-connection) (deprecated) | Creates VPC endpoint services and an IAM role so Ververica Cloud can reach resources (RDS, MSK, ElastiCache, …) running in your VPC. |
| [`vpc-endpoint-service`](./modules/vpc-endpoint-service) (deprecated) | Lower-level building block used by `private-connection` to expose a single service via an NLB-fronted VPC endpoint service. |