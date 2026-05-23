output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID attached to the VPC."
  value       = aws_internet_gateway.this.id
}

output "availability_zones" {
  description = "AZs used by public and private subnets."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs (EC2 / app tier)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (RDS / data tier)."
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of public subnets."
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets."
  value       = aws_subnet.private[*].cidr_block
}

output "public_route_table_id" {
  description = "Route table for public subnets (default route to IGW)."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Route table for private subnets (no internet default route)."
  value       = aws_route_table.private.id
}
