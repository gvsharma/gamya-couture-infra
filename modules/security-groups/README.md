# security-groups

Least-privilege security groups for the Gamya Couture MVP: public **EC2 app tier** and private **RDS PostgreSQL**.

## Rules

### EC2 (`ec2_security_group_id`)

| Direction | Port | Source | Purpose |
|-----------|------|--------|---------|
| Ingress | 80 | `web_ingress_cidr_blocks` (default `0.0.0.0/0`) | HTTP API / redirect |
| Ingress | 443 | `web_ingress_cidr_blocks` | HTTPS API |
| Ingress | 22 | `admin_cidr` only | SSH (prefer SSM in production) |
| Egress | all | `0.0.0.0/0` (optional) | Docker, OS updates, external APIs |

### RDS (`rds_security_group_id`)

| Direction | Port | Source | Purpose |
|-----------|------|--------|---------|
| Ingress | 5432 | EC2 security group | PostgreSQL from app only |
| Egress | — | *(none)* | No outbound internet |

RDS is not reachable from the public internet or from arbitrary VPC CIDRs—only from instances using the EC2 security group.

## Usage

```hcl
module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix = "gamya-couture-prod"
  vpc_id      = module.vpc.vpc_id
  admin_cidr  = "203.0.113.10/32"
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name_prefix` | string | — | Name prefix |
| `vpc_id` | string | — | VPC ID |
| `admin_cidr` | string | — | Admin IP for SSH (`/32` recommended) |
| `web_ingress_cidr_blocks` | list(string) | `["0.0.0.0/0"]` | HTTP/HTTPS sources |
| `allow_ec2_all_egress` | bool | `true` | Full outbound for EC2 |

## Outputs

| Name | Description |
|------|-------------|
| `ec2_security_group_id` | Attach to EC2 instance |
| `ec2_security_group_arn` | EC2 SG ARN |
| `rds_security_group_id` | Attach to RDS instance |
| `rds_security_group_arn` | RDS SG ARN |

## Hardening tips

1. Set `admin_cidr` to your current public IP `/32`; update when your IP changes.
2. Prefer **SSM Session Manager** and remove port 22 later if desired.
3. To restrict HTTP/S to CloudFront only, set `web_ingress_cidr_blocks` to [AWS managed prefix lists](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/LocationsOfEdgeServers.html) or use ALB (out of scope for cost MVP).

## Downstream

- **ec2** → `ec2_security_group_id`
- **rds** → `vpc_security_group_ids = [rds_security_group_id]`
