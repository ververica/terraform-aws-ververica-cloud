###########################################################
## Private Connections with VPC Endpoint Services        ##
###########################################################
module "vpc_endpoint_service" {
  for_each = var.endpoint_services
  source   = "../vpc-endpoint-service"

  create_security_group_rule      = lookup(each.value, "create_security_group_rule", false)
  security_group_rule_description = lookup(each.value, "security_group_rule_description", "Allow access from Ververica Cloud")
  security_group_id               = lookup(each.value, "security_group_id", null)
  vpc_id                          = lookup(each.value, "vpc_id", null)
  port                            = lookup(each.value, "port", null)
  nodes                           = lookup(each.value, "nodes", null)
  principal_arn                   = lookup(each.value, "principal_arn", "arn:aws:iam::794031221915:root")
  tags                            = lookup(each.value, "tags", null)
}
