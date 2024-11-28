variable "ververica_cloud_aws_account" {
  description = "The AWS Account ID of Ververica Cloud"
  type        = string
  default     = "794031221915"
}

variable "ververica_cloud_workspace_id" {
  description = "The Ververica Cloud Workspace ID"
  type        = string
}

variable "role_name" {
  description = "The name for the IAM role to be created in your AWS Account."
  type        = string
  default     = null
}

variable "role_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = ""
}

variable "role_description" {
  description = "IAM Role description"
  type        = string
  default     = "The IAM Role used with Ververica Cloud to access various AWS Services in this account"
}

variable "role_name_prefix" {
  description = "IAM role name prefix"
  type        = string
  default     = null
}

variable "force_detach_policies" {
  description = "Whether policies should be detached from this role when destroying"
  type        = bool
  default     = false
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = 43200
}

variable "tags" {
  description = "A map of tags to add the the IAM role"
  type        = map(any)
  default     = {}
}

variable "enable_glue" {
  description = "Enable the AWS Glue Catalog Policies"
  type        = bool
  default     = false
}

variable "glue_arns" {
  description = "A list of AWS Glue ARNs that Ververica Cloud will have access to"
  type        = list(string)
  default     = null
}

variable "enable_kinesis" {
  description = "Enable the Kinesis IAM Policies"
  type        = bool
  default     = false
}

variable "kinesis_stream_arns" {
  description = "A list of Kinesis Stream ARNs that Ververica Cloud will have access to"
  type        = list(string)
  default     = null
}

variable "enable_dynamodb" {
  description = "Enable the DynamoDB IAM Policies"
  type        = bool
  default     = false
}

variable "dynamodb_table_arns" {
  description = "A list of DynamoDB Table ARNs that Ververica Cloud will have access to"
  type        = list(string)
  default     = null
}

variable "enable_s3" {
  description = "Enable the S3 IAM Policies"
  type        = bool
  default     = false
}

variable "s3_bucket_arns" {
  description = "A list of S3 Bucket ARNs that Ververica Cloud will have access to"
  type        = list(string)
  default     = null
}

variable "enable_elasticache" {
  description = "Enable the Elasticache IAM Policies"
  type        = bool
  default     = false
}

variable "enable_msk" {
  description = "Enable the MSK IAM Policies"
  type        = bool
  default     = false
}

variable "enable_private_connection" {
  description = "Enable the VPC Endpoint IAM Policies"
  type        = bool
  default     = false
}

variable "endpoint_services" {
  description = "A map of maps containing VPC Endpoint Service configuration. Can contain 0..N maps of VPC Endpoint Services."
  type        = any
}

