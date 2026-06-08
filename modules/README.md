# Terraform modules

Reusable modules for **gamya-couture-infra**. Naming prefix: `gamya-couture-{environment}`.

## Core (active)

| Module | Purpose | Status |
|--------|---------|--------|
| [vpc](./vpc/) | VPC, subnets, IGW, routes | **Active** |
| [security-groups](./security-groups/) | EC2 + RDS security groups | **Active** |
| [ec2](./ec2/) | App server (Docker, nginx, SSM) | **Active** |

## Data & storage (active)

| Module | Purpose | Status |
|--------|---------|--------|
| [rds](./rds/) | PostgreSQL 16 | **Active** |
| [scheduler](./scheduler/) | RDS stop/start (IST) | **Active** |
| [s3](./s3/) | Frontend + media buckets | **Active** |

## Edge & DNS (active)

| Module | Purpose | Status |
|--------|---------|--------|
| [cloudfront](./cloudfront/) | CDN + HTTPS | **Active** |
| [route53](./route53/) | Hosted zone | **Active** |
| [route53-records](./route53-records/) | DNS aliases | **Active** |
| [acm](./acm/) | TLS certificates (us-east-1) | **Active** |

## Future / optional

| Module | Purpose | Status |
|--------|---------|--------|
| [alb](./alb/) | Application Load Balancer | **Planned** |
| [ci-deploy-iam](./ci-deploy-iam/) | GitHub Actions frontend deploy | Optional |
| [ci-terraform-iam](./ci-terraform-iam/) | GitHub Actions Terraform OIDC | Bootstrap |

## Legacy alias

| Module | Note |
|--------|------|
| [networking](./networking/) | Deprecated — use **vpc** |
