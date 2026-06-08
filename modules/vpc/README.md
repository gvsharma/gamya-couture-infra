# vpc

Production VPC for Gamya Couture: **2 public + 2 private subnets**, Internet Gateway, route tables. **No NAT Gateway** (cost optimization).

## Resources

- `aws_vpc`
- `aws_internet_gateway`
- `aws_subnet` (public × 2, private × 2)
- `aws_route_table` + associations

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "gamya-couture-prod"
  vpc_cidr    = "10.0.0.0/16"
}
```

## Outputs

| Output | Use |
|--------|-----|
| `vpc_id` | Security groups, RDS |
| `public_subnet_ids` | EC2 |
| `private_subnet_ids` | RDS subnet group |
