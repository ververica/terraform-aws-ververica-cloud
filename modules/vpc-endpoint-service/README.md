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
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [aws_vpc_endpoint_service_allowed_principal.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service_allowed_principal) | resource |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_security_group_rule"></a> [create\_security\_group\_rule](#input\_create\_security\_group\_rule) | Whether to add the security group rule or not | `bool` | `false` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | A list of objects containing DNS endpoint, IP Address, and Subnet ID for the Service that we create the resources. | <pre>list(object({<br>    dns_endpoint = string<br>    ip_address   = string<br>    subnet_id    = string<br>  }))</pre> | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | The port that Ververica Cloud is going to use to access your service. eg Elasticache is 6379, MSK with IAM is 9098, etc. | `number` | n/a | yes |
| <a name="input_principal_arn"></a> [principal\_arn](#input\_principal\_arn) | The principal ARN that will have access to the Endpoint Service. Default value is the Ververica Cloud AWS Account ID | `string` | `"arn:aws:iam::794031221915:root"` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | The security group ID to which the module adds a new rule. | `string` | `""` | no |
| <a name="input_security_group_rule_description"></a> [security\_group\_rule\_description](#input\_security\_group\_rule\_description) | A description for the security group rule | `string` | `"Allow access from Ververica Cloud"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID where the AWS service exists and where the resources will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | The VPC Endpoint Services that Ververica Cloud can have access to. Contains the Service Name and Endpoint for ease of input to Ververica Cloud Private Connection UI. |
