# Gamya Couture — AWS Infrastructure (Terraform)

Cost-optimized production infrastructure for the Gamya Couture boutique website and CRM MVP.

| Item | Value |
|------|--------|
| Region | `ap-south-1` (Mumbai) |
| Budget target | ≤ ₹3,000 / month |
| Traffic profile | ~500 website hits / day |
| IaC | Terraform ≥ 1.8 |

## Architecture (high level)

```
Internet
   │
   ├─► CloudFront ──► S3 (Next.js static export)
   │
   ├─► Route53 ──► EC2 (public subnet, Docker / Spring Boot)
   │                    │
   │                    └──► RDS PostgreSQL (private subnet, no public access)
   │
   └─► S3 (product media) ◄── EC2 via IAM (no NAT, no VPC endpoints)

Ops: SSM Session Manager (no bastion). SSH restricted to allowlisted IP.
```

**Explicitly excluded:** NAT Gateway, ALB, ECS/EKS, Lambda backend, Aurora, CodePipeline, VPC endpoints, Transit Gateway.

## Cost model (approximate)

| Resource | Notes | ~USD/mo |
|----------|--------|---------|
| EC2 `t4g.micro` | Single app host, 8 GB gp3 root | 6–8 |
| RDS `db.t4g.micro` | gp3 20 GB; stopped 00:00–07:00 IST (~29% off compute) | 8–12 |
| S3 + CloudFront | Low traffic static + media | 1–3 |
| Route53 | 1 hosted zone + queries | 1 |
| CloudWatch | 4-day retention, few alarms | 1–2 |
| EBS snapshots | None for RDS (per spec) | 0 |
| **NAT / ALB / ECS** | **Not used** | **0** |

≈ **$20–28 USD** (~₹1,700–2,400) with disciplined usage — leaves headroom for data transfer spikes.

## Incremental delivery plan

| Phase | Scope | Status |
|-------|--------|--------|
| **1** | Repo bootstrap, providers, tagging, env skeleton, backend docs | **Current** |
| **2** | `modules/networking` — VPC, 2 public + 2 private subnets, IGW, routes (no NAT) | **Done** |
| **3** | `modules/security-groups` — EC2/RDS SGs (SSM/IAM in ec2 module later) | **Done** |
| **4** | `modules/rds` — PostgreSQL 16, SSM secrets, 4d logs | **Done** |
| **5** | `modules/scheduler` — EventBridge Scheduler + Lambda (IST stop/start) | **Done** |
| **6** | `modules/ec2` — AL2023 ARM, Docker, nginx, EIP, SSM, CW logs | **Done** |
| **7** | `modules/s3` — frontend, images, videos buckets | **Done** |
| **8** | `modules/cloudfront` — CDN, OAC, HTTPS, image-ready paths | **Done** |
| **9** | `modules/route53`, `acm`, `route53-records` — DNS + TLS | **Done** |
| **10** | `modules/cloudwatch` — 4-day retention, basic alarms |
| **11** | Wire `environments/prod` (then `dev` with smaller flags) |

## Repository layout

```
gamya-couture-infra/
├── README.md                 # This file
├── .gitignore
├── bootstrap/                # S3 state + DynamoDB locks (apply once)
├── docs/
│   └── COST_AND_OPS.md       # Runbooks, cost levers
├── global/
│   └── tags.tf               # Shared default_tags for all modules
├── environments/
│   ├── dev/                  # Smaller / optional RDS schedule overrides
│   └── prod/                 # Production root module composition
└── modules/
    ├── networking/
    ├── security/
    ├── iam/
    ├── rds/
    ├── rds-scheduler/
    ├── ec2-app/
    ├── s3-static-site/
    ├── s3-media/
    ├── cloudfront/
    ├── route53/
    └── cloudwatch/
```

## Prerequisites

1. AWS account with billing alerts (recommend ₹2,500 warning).
2. Terraform ≥ 1.8, AWS CLI v2 configured.
3. Domain in Route53 (or ready to delegate NS).
4. Your public IP for SSH allowlist (`/32`).

## Bootstrap (remote state)

One-time setup in [`bootstrap/`](bootstrap/README.md):

```bash
cd bootstrap && terraform init && terraform apply
cd ../environments/prod
terraform init -backend-config=../../bootstrap/examples/backend.prod.hcl
```

See [bootstrap/README.md](bootstrap/README.md) for IAM attachment and state migration.

See [docs/COST_AND_OPS.md](docs/COST_AND_OPS.md) for day-2 operations.

See [docs/INFRASTRUCTURE_REVIEW.md](docs/INFRASTRUCTURE_REVIEW.md) for architecture review, cost estimate, security risks, and deployment order.

## Usage (after modules are added)

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Tagging strategy

All resources inherit:

| Tag | Example |
|-----|---------|
| `Project` | `gamya-couture` |
| `Environment` | `prod` / `dev` |
| `ManagedBy` | `terraform` |
| `Owner` | `platform` |
| `CostCenter` | `mvp` |

## Contributing

One module per PR phase. Run `terraform fmt -recursive` before commit.
