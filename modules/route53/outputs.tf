output "zone_id" {
  description = "Route53 hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "zone_arn" {
  description = "Route53 hosted zone ARN."
  value       = aws_route53_zone.this.arn
}

output "name_servers" {
  description = "Delegate these NS records at your domain registrar."
  value       = aws_route53_zone.this.name_servers
}

output "domain_name" {
  description = "Root domain name."
  value       = aws_route53_zone.this.name
}
