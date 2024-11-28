## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc_endpoint_service"></a> [vpc\_endpoint\_service](#module\_vpc\_endpoint\_service) | ../vpc-endpoint-service | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.ververica_cloud_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.private_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.private_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dynamodb_table_arns"></a> [dynamodb\_table\_arns](#input\_dynamodb\_table\_arns) | A list of DynamoDB Table ARNs that Ververica Cloud will have access to | `list(string)` | `null` | no |
| <a name="input_enable_dynamodb"></a> [enable\_dynamodb](#input\_enable\_dynamodb) | Enable the DynamoDB IAM Policies | `bool` | `false` | no |
| <a name="input_enable_elasticache"></a> [enable\_elasticache](#input\_enable\_elasticache) | Enable the Elasticache IAM Policies | `bool` | `false` | no |
| <a name="input_enable_glue"></a> [enable\_glue](#input\_enable\_glue) | Enable the AWS Glue IAM Policies | `bool` | `false` | no |
| <a name="input_enable_kinesis"></a> [enable\_kinesis](#input\_enable\_kinesis) | Enable the Kinesis IAM Policies | `bool` | `false` | no |
| <a name="input_enable_msk"></a> [enable\_msk](#input\_enable\_msk) | Enable the MSK IAM Policies | `bool` | `false` | no |
| <a name="input_enable_private_connection"></a> [enable\_private\_connection](#input\_enable\_private\_connection) | Enable the VPC Endpoint IAM Policies | `bool` | `false` | no |
| <a name="input_enable_s3"></a> [enable\_s3](#input\_enable\_s3) | Enable the S3 IAM Policies | `bool` | `false` | no |
| <a name="input_endpoint_services"></a> [endpoint\_services](#input\_endpoint\_services) | A map of maps containing VPC Endpoint Service configuration. Can contain 0..N maps of VPC Endpoint Services. | `any` | n/a | yes |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Whether policies should be detached from this role when destroying | `bool` | `false` | no |
| <a name="input_kinesis_stream_arns"></a> [kinesis\_stream\_arns](#input\_kinesis\_stream\_arns) | A list of Kinesis Stream ARNs that Ververica Cloud will have access to | `list(string)` | `null` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum CLI/API session duration in seconds between 3600 and 43200 | `number` | `43200` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | IAM Role description | `string` | `"The IAM Role used with Ververica Cloud to access various AWS Services in this account"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name for the IAM role to be created in your AWS Account. | `string` | `null` | no |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix) | IAM role name prefix | `string` | `null` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | Path of IAM role | `string` | `"/"` | no |
| <a name="input_role_permissions_boundary_arn"></a> [role\_permissions\_boundary\_arn](#input\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for IAM role | `string` | `""` | no |
| <a name="input_s3_bucket_arns"></a> [s3\_bucket\_arns](#input\_s3\_bucket\_arns) | A list of S3 Bucket ARNs that Ververica Cloud will have access to | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add the the IAM role | `map(any)` | `{}` | no |
| <a name="input_ververica_cloud_aws_account"></a> [ververica\_cloud\_aws\_account](#input\_ververica\_cloud\_aws\_account) | The AWS Account ID of Ververica Cloud | `string` | `"794031221915"` | no |
| <a name="input_ververica_cloud_workspace_id"></a> [ververica\_cloud\_workspace\_id](#input\_ververica\_cloud\_workspace\_id) | The Ververica Cloud Workspace ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enabled_policies"></a> [enabled\_policies](#output\_enabled\_policies) | The IAM policies that are enabled for the IAM Role |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | The VPC Endpoint Services that Ververica Cloud can have access to. Contains the Service Name and Endpoint for ease of input to Ververica Cloud Private Connection UI. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The ARN of the IAM Role |
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | The name of the IAM Role |
