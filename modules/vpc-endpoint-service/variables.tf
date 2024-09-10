variable "create_security_group_rule" {
  description = "Whether to add the security group rule or not"
  type        = bool
  default     = false
}

variable "security_group_rule_description" {
  description = "A description for the security group rule"
  type        = string
  default     = "Allow access from Ververica Cloud"
}

variable "security_group_id" {
  description = "The security group ID to which the module adds a new rule."
  type        = string
  default     = ""
}

variable "port" {
  description = "The port that Ververica Cloud is going to use to access your service. eg Elasticache is 6379, MSK with IAM is 9098, etc."
  type        = number
}

variable "principal_arn" {
  description = "The principal ARN that will have access to the Endpoint Service. Default value is the Ververica Cloud AWS Account ID"
  type        = string
  default     = "arn:aws:iam::794031221915:root"
}

variable "vpc_id" {
  description = "The VPC ID where the AWS service exists and where the resources will be created."
  type        = string
}

variable "nodes" {
  description = "A list of objects containing DNS endpoint, IP Address, and Subnet ID for the Service that we create the resources."
  type = list(object({
    dns_endpoint = string
    ip_address   = string
    subnet_id    = string
  }))
  # Example
  # [
  #   {
  #     dns_endpoint = "b-1.democluster1.abcdef.c1.kafka.eu-central-1.amazonaws.com"
  #     ip_address   = "172.31.40.27"
  #     subnet_id    = "subnet-14cf73a7634ac123"
  #   }
  # ]
}

variable "tags" {
  description = "A map of tags to add to the resources."
  type        = map(string)
  default     = {}
}
