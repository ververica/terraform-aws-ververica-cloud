provider "aws" {
  region = "eu-central-1"
}


module "rds_private_connection" {
  source = "ververica/ververica-cloud/aws//modules/vpc-endpoint-service"

  vpc_id                     = "vpc-1234567890abcdefg"
  create_security_group_rule = true
  security_group_id          = "sg-1234567890abcdefg"
  port                       = 3306
  nodes = [
    {
      # You need to use the instance endpoint of the Write instance and its subnet.
      # To get the ip you can use something like: dig +short <dns_endpoint>
      ip_address   = "172.31.40.27"
      dns_endpoint = "demo-database-1-instance-1.abcdefg8ek.0001.eu-central-1.rds.amazonaws.com"
      subnet_id    = "subnet-1234567890abcdefg"
    }
  ]
  tags = {
    Description = "Used for Ververica Cloud"
  }
}
