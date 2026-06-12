# Terraform modules

Reusable modules for **gamya-couture-infra**. Naming prefix: `gamya-couture-{environment}`.

## Minimal API stack (Vercel backend)

| Module | Purpose | Status |
|--------|---------|--------|
| [vpc-minimal](./vpc-minimal/) | VPC, 1 public + 2 private subnets, IGW | **Active** |
| [security-groups-api](./security-groups-api/) | API EC2 + RDS SG (HTTP/HTTPS + SSH) | **Active** |
| [ec2-api](./ec2-api/) | AL2023 `t3.micro`, nginx, SSM agent, deploy bootstrap | **Active** |
| [backend-deploy-s3](./backend-deploy-s3/) | S3 bucket for backend JAR artifacts | **Active** |
| [ci-backend-deploy-iam](./ci-backend-deploy-iam/) | GitHub OIDC → S3 + SSM deploy | **Active** |

Environment: [`environments/dev`](../environments/dev/) (dev only)

## Core (full prod)

| Module | Purpose | Status |
|--------|---------|--------|
| [vpc](./vpc/) | VPC, subnets, IGW, routes | **Active** |
| [security-groups](./security-groups/) | EC2 + RDS security groups | **Active** |
| [ec2](./ec2/) | App server (Docker, nginx, SSM) | **Active** |

## Data & storage (active)

| Module | Purpose | Status |
|--------|---------|--------|
| [rds](./rds/) | PostgreSQL 16 | **Active** |
| [scheduler](./scheduler/) | EC2 + RDS stop/start (00:00–09:00 IST) | **Active** |
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
| [ci-terraform-iam](./ci-terraform-iam/) | GitHub OIDC + `GitHubTerraformRole` | [github-oidc/](../github-oidc/) or bootstrap |

## Legacy alias

| Module | Note |
|--------|------|
| [networking](./networking/) | Deprecated — use **vpc** |
