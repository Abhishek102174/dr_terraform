resource "aws_route53_zone" "this" {
 name          = var.domain_name
 comment       = var.comment
 force_destroy = false
 tags          = var.tags
 dynamic "vpc" {
   for_each = var.private_zone ? var.vpc_associations : []
   content {
     vpc_id     = vpc.value.vpc_id
     vpc_region = vpc.value.vpc_region
   }
 }
}
locals {
 health_check_protocol = var.enable_https ? "HTTPS" : var.health_check_protocol
 health_check_port     = var.enable_https ? 443 : var.health_check_port
}

resource "aws_route53_health_check" "this" {
 count = var.health_check_fqdn != "" ? 1 : 0
 fqdn              = var.health_check_fqdn
 port              = local.health_check_port
 type              = local.health_check_protocol
 resource_path     = local.health_check_protocol != "TCP" ? var.health_check_path : null
 regions           = var.health_check_regions
 failure_threshold = 3
 request_interval  = 30
 tags              = var.tags
}
resource "aws_route53_record" "this" {
  for_each = { for idx, record in var.records : idx => record }
  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type

  # Ensure TTL and records are specified for CNAME
  ttl     = lookup(each.value, "ttl", var.record_default_ttl)
  records = lookup(each.value, "records", null)

  # Alias block (conditionally included)
  dynamic "alias" {
    for_each = can(each.value.alias) && each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = true
    }
  }

  set_identifier  = lookup(each.value, "set_identifier", null)
  health_check_id = lookup(each.value, "health_check_id", null)

  # Failover routing policy (conditionally included)
  dynamic "failover_routing_policy" {
    for_each = can(each.value.failover_routing_policy) && each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  # Weighted routing policy (conditionally included)
  dynamic "weighted_routing_policy" {
    for_each = can(each.value.weighted_routing_policy) && each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  # Latency routing policy (conditionally included)
  dynamic "latency_routing_policy" {
    for_each = can(each.value.latency_routing_policy) && each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }
}
