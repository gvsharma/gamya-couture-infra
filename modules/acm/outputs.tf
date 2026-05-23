output "certificate_arn" {
  description = "Issued ACM certificate ARN (us-east-1) for CloudFront."
  value       = aws_acm_certificate.this.arn
}

output "certificate_arn_validated" {
  description = "Validated certificate ARN (use for CloudFront aliases)."
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "domain_name" {
  description = "Primary certificate domain."
  value       = aws_acm_certificate.this.domain_name
}

output "subject_alternative_names" {
  description = "Certificate SANs."
  value       = aws_acm_certificate.this.subject_alternative_names
}

output "validation_record_fqdns" {
  description = "DNS validation record FQDNs created in Route53."
  value       = [for record in aws_route53_record.validation : record.fqdn]
}
