resource "random_string" "this" {
  length  = 6
  special = false
}

resource "aws_security_group_rule" "this" {
  count             = var.create_security_group_rule ? 1 : 0
  description       = var.security_group_rule_description
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_lb_target_group" "this" {
  count       = length(var.nodes)
  name        = "node-lb-target-group-${count.index}-${random_string.this.result}"
  port        = var.port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.nodes)
  target_group_arn = aws_lb_target_group.this[count.index].arn
  target_id        = var.nodes[count.index].ip_address
  port             = var.port
}

resource "aws_lb" "this" {
  count                            = length(var.nodes)
  name                             = "node-lb-${count.index}-${random_string.this.result}"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = [var.nodes[count.index].subnet_id]
  enable_cross_zone_load_balancing = false
  tags                             = var.tags
}

resource "aws_lb_listener" "this" {
  count             = length(var.nodes)
  load_balancer_arn = aws_lb.this[count.index].arn
  port              = var.port
  protocol          = "TCP"
  tags              = var.tags

  default_action {
    target_group_arn = aws_lb_target_group.this[count.index].arn
    type             = "forward"
  }
}

resource "aws_vpc_endpoint_service" "this" {
  count                      = length(var.nodes)
  acceptance_required        = true
  network_load_balancer_arns = [aws_lb.this[count.index].arn]
  tags                       = var.tags
}

resource "aws_vpc_endpoint_service_allowed_principal" "this" {
  count                   = length(var.nodes)
  principal_arn           = var.principal_arn
  vpc_endpoint_service_id = aws_vpc_endpoint_service.this[count.index].id
}
