## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_msk_private_connection"></a> [msk\_private\_connection](#module\_msk\_private\_connection) | ververica/ververica-cloud/aws//modules/vpc-endpoint-service | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_msk_broker_nodes.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/msk_broker_nodes) | data source |
| [aws_msk_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/msk_cluster) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | n/a |
