output "iam_role_id" {
  description = "The name of the IAM Role"
  value       = aws_iam_role.ververica_cloud_iam_role.id
}

output "iam_role_arn" {
  description = "The ARN of the IAM Role"
  value       = aws_iam_role.ververica_cloud_iam_role.arn
}

output "enabled_policies" {
  description = "The IAM policies that are enabled for the IAM Role"
  value = {
    Glue              = var.enable_glue
    Kinesis           = var.enable_kinesis
    DynamoDB          = var.enable_dynamodb
    S3                = var.enable_s3
    Elasticache       = var.enable_elasticache
    MSK               = var.enable_msk
    PrivateConnection = local.enable_private_connection
  }
}

output "endpoints" {
  description = "The VPC Endpoint Services that Ververica Cloud can have access to. Contains the Service Name and Endpoint for ease of input to Ververica Cloud Private Connection UI."
  value = {
    for k, endpoint in module.vpc_endpoint_service : k => endpoint.endpoints
  }
}
