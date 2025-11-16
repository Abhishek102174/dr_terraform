output "hosted_zone_id" {
 description = "Route53 Hosted Zone ID"
 value       = aws_route53_zone.this.zone_id
}
output "name_servers" {
 description = "Hosted zone name servers"
 value       = aws_route53_zone.this.name_servers
}
output "health_check_id" {
 description = "Route53 Health Check ID"
 value       = try(aws_route53_health_check.this[0].id, "")
}
output "record_fqdns" {
 description = "FQDNs of created records"
 value = {
   for idx, record in aws_route53_record.this :
   var.records[idx].name => record.fqdn...
 }
}