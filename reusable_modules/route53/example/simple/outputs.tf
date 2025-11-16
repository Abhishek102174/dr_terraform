output "public_zone_id" {
  value = module.public_zone.hosted_zone_id
}

output "private_zone_id" {
  value = module.private_zone.hosted_zone_id
}

output "private_zone_nameservers" {
  value = module.private_zone.name_servers
}

output "https_health_check_id" {
  value = module.https_health_check.health_check_id
}

output "public_zone_records" {
  value = module.public_zone.record_fqdns
}

output "failover_records" {
  value = module.https_health_check.record_fqdns
}