provider "aws" {
  region = "eu-central-1"
}

module "private_connection" {
  source = "ververica/ververica-cloud/aws//modules/private-connection"

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
