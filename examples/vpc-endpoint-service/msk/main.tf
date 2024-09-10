provider "aws" {
  region = "eu-central-1"
}

data "aws_msk_cluster" "this" {
  cluster_name = "demo-cluster-1"
}

data "aws_msk_broker_nodes" "this" {
  cluster_arn = data.aws_msk_cluster.this.arn
}

module "msk_private_connection" {
  source = "ververica/ververica-cloud/aws//modules/vpc-endpoint-service"

  vpc_id                     = "vpc-1234567890abcdefg"
  create_security_group_rule = true
  security_group_id          = "sg-1234567890abcdefg"
  port                       = 9098
  nodes = [for broker in data.aws_msk_broker_nodes.this.node_info_list : {
    ip_address   = broker.client_vpc_ip_address
    dns_endpoint = one(broker.endpoints)
    subnet_id    = broker.client_subnet
  }]
  tags = {
    Description = "Used for Ververica Cloud"
  }
}
