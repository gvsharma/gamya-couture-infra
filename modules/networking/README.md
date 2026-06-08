# networking (deprecated)

> **Use [`modules/vpc`](../vpc/) instead.** This module is kept for backward compatibility only.

# networking

Reusable VPC module for Gamya Couture: one VPC, two public subnets (EC2), two private subnets (RDS), Internet Gateway, and route tables — **without a NAT Gateway**.

## Architecture

```
                    Internet
                        │
                        ▼
                 Internet Gateway
                        │
        ┌───────────────┴───────────────┐
        │         Public RT           │
        │      0.0.0.0/0 → IGW        │
        └───────────────┬───────────────┘
                        │
         ┌──────────────┴──────────────┐
         │                             │
   public-subnet-a               public-subnet-b
   (EC2 / Spring Boot)           (standby AZ)
         │                             │
         └──────────────┬──────────────┘
                        │  VPC internal routing
         ┌──────────────┴──────────────┐
         │                             │
  private-subnet-a              private-subnet-b
  (RDS primary AZ)              (RDS standby AZ)
         ▲
         │  Private RT — no 0.0.0.0/0 route
         │  (no NAT, no internet egress)
```

## Why NAT is intentionally excluded

| Topic | Explanation |
|-------|-------------|
| **Cost** | A single NAT Gateway in `ap-south-1` costs roughly **$32+/month** plus data processing — often more than EC2 + RDS combined for this MVP. |
| **Traffic profile** | ~500 site hits/day; the API needs inbound HTTPS and outbound internet from **one** EC2 host, not from private subnets. |
| **Design** | EC2 runs in a **public** subnet with a public IP and security-group restrictions. RDS stays in **private** subnets with **no public access**; only the app SG can reach port 5432. |
| **Trade-off** | Private subnets cannot reach the internet (no OS patches via public repos from RDS — N/A for RDS; no Lambda in VPC). Acceptable for this stack. |
| **Security** | RDS is not exposed to the internet. EC2 exposure is limited by SG (SSH from admin IP, app ports, SSM). |

NAT would only be required if you moved the app tier to private subnets while still needing outbound internet (Docker pulls, external APIs). That is out of scope for the ₹3,000/month budget.

## Default subnet layout

For `vpc_cidr = 10.0.0.0/16`:

| Subnet | CIDR | Tier |
|--------|------|------|
| public AZ-a | `10.0.1.0/24` | EC2 |
| public AZ-b | `10.0.2.0/24` | EC2 |
| private AZ-a | `10.0.11.0/24` | RDS |
| private AZ-b | `10.0.12.0/24` | RDS |

Override with `public_subnet_cidrs` / `private_subnet_cidrs` if needed.

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  name_prefix = "gamya-couture-prod"
  vpc_cidr    = "10.0.0.0/16"
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name_prefix` | string | — | Resource name prefix |
| `vpc_cidr` | string | — | VPC CIDR |
| `availability_zones` | list(string) | `[]` | Two AZs or auto-select |
| `public_subnet_cidrs` | list(string) | `[]` | Optional explicit public CIDRs |
| `private_subnet_cidrs` | list(string) | `[]` | Optional explicit private CIDRs |
| `map_public_ip_on_launch` | bool | `true` | Public IP for EC2 subnets |
| `enable_dns_hostnames` | bool | `true` | VPC DNS hostnames |
| `enable_dns_support` | bool | `true` | VPC DNS support |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr_block` | VPC CIDR |
| `internet_gateway_id` | IGW ID |
| `availability_zones` | AZ list |
| `public_subnet_ids` | For EC2 module |
| `private_subnet_ids` | For RDS subnet group |
| `public_subnet_cidrs` | CIDR list |
| `private_subnet_cidrs` | CIDR list |
| `public_route_table_id` | Public RT |
| `private_route_table_id` | Private RT |

## Downstream modules

- **ec2** — use `public_subnet_ids[0]` (or spread across AZs for HA later)
- **rds** — `aws_db_subnet_group` with `private_subnet_ids`
- **security-groups** — reference `vpc_id`

## Cost

VPC, subnets, route tables, and IGW have **no hourly charge**. You pay only for resources placed inside subnets (EC2, RDS, data transfer).
