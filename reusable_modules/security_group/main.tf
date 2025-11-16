# Security Group
resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = var.tags
}

# Ingress Rules
resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  type              = "ingress"
  security_group_id = aws_security_group.this.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks  = try(each.value.ipv6_cidr_blocks, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
  self              = try(each.value.self, null)
  description       = try(each.value.description, null)
}

# Egress Rules
resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  type              = "egress"
  security_group_id = aws_security_group.this.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks  = try(each.value.ipv6_cidr_blocks, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
  self              = try(each.value.self, null)
  description       = try(each.value.description, null)
}