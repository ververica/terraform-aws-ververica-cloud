output "endpoints" {
  description = "The VPC Endpoint Services that Ververica Cloud can have access to. Contains the Service Name and Endpoint for ease of input to Ververica Cloud Private Connection UI."
  value = [for idx, endpoint in aws_vpc_endpoint_service.this : {
    service_name = endpoint.service_name
    endpoint     = var.nodes[idx].dns_endpoint
  }]
}
