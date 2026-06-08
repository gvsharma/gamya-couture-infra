# gamya-couture-infra

Production-ready Terraform for **Gamya Couture** on AWS (`ap-south-1`).

| Item | Value |
|------|--------|
| Region | `ap-south-1` (Mumbai) |
| Terraform | `>= 1.9.0` |
| Naming prefix | `gamya-couture` |
| State bucket | `gamya-couture-terraform-state` |
| State lock table | `terraform-locks` |
| Prod state key | `infra/terraform.tfstate` |

## Repository layout

```
gamya-couture-infra/
├── README.md
├── bootstrap/                    # One-time: S3 state + DynamoDB + GitHub OIDC (optional)
├── global/                       # Shared default_tags
├── environments/
│   └── prod/                     # Production stack
│       ├── backend.tf            # S3 remote backend (embedded)
│       ├── providers.tf          # AWS providers ap-south-1 + us-east-1
│       ├── variables.tf
│       ├── locals.tf
│       ├── main.tf               # Module composition
│       ├── outputs.tf
│       ├── ci.tfvars             # Non-secret defaults for GitHub Actions
│       └── terraform.tfvars.example
├── modules/
│   ├── vpc/                      # VPC, subnets, IGW
│   ├── security-groups/          # EC2 + RDS SGs
│   ├── ec2/                      # Application server
│   ├── rds/                      # PostgreSQL
│   ├── s3/                       # Static + media buckets
│   ├── cloudfront/               # CDN
│   ├── route53/                  # DNS zone
│   ├── route53-records/          # DNS records
│   ├── acm/                      # TLS (us-east-1)
│   ├── scheduler/                # RDS cost schedule
│   ├── alb/                      # Future: load balancer
│   └── README.md                 # Module index
├── .github/workflows/terraform.yml  # CI: plan on PR, apply on push to main
└── docs/
    ├── GITHUB_ACTIONS.md
    ├── COST_AND_OPS.md
    └── INFRASTRUCTURE_REVIEW.md
```

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.9.0`
2. [AWS CLI](https://aws.amazon.com/cli/) configured (`aws sts get-caller-identity`)
3. S3 bucket **`gamya-couture-terraform-state`** and DynamoDB table **`terraform-locks`** in `ap-south-1` (create via `bootstrap/` or manually)

## Quick start

### 1. Remote state (if not already created)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
```

Skip if your bucket and lock table already exist.

### 2. Deploy production

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform plan
terraform apply
```

`backend.tf` is preconfigured:

```hcl
terraform {
  backend "s3" {
    bucket         = "gamya-couture-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### 3. GitHub Actions (optional)

See [docs/GITHUB_ACTIONS.md](docs/GITHUB_ACTIONS.md). Plan on PR; apply on merge to `main` (OIDC via `AWS_ROLE_ARN` secret).

## Architecture

```
Internet
   ├─► CloudFront ──► S3 (Next.js static)
   ├─► Route53 ──► EC2 (Docker / API) ──► RDS PostgreSQL (private)
   └─► S3 media ◄── EC2 (IAM)
```

**Cost choices:** no NAT Gateway, no ALB, RDS scheduled off-hours (optional).

## Modules

| Layer | Module | Description |
|-------|--------|-------------|
| Network | `vpc` | VPC, 2 public + 2 private subnets, IGW |
| Security | `security-groups` | EC2 + RDS rules |
| Compute | `ec2` | ARM instance, EIP, SSM |
| Data | `rds` | PostgreSQL 16 |
| Storage | `s3` | Frontend, images, videos |
| Edge | `cloudfront`, `route53`, `acm` | HTTPS CDN + DNS |
| Future | `alb` | Placeholder for load balancer |

## Tagging

All resources receive `default_tags` from `global/tags.tf`:

| Tag | Example |
|-----|---------|
| `Project` | `gamya-couture` |
| `Environment` | `prod` |
| `ManagedBy` | `terraform` |

## Conventions

- **Name prefix:** `{project}-{environment}` → `gamya-couture-prod`
- **One state file per environment** under `infra/` prefix in the state bucket
- **Secrets:** gitignored `terraform.tfvars`; CI uses `ci.tfvars`
- **Fmt:** `terraform fmt -recursive` before commit

## Documentation

- [Module index](modules/README.md)
- [Bootstrap / state](bootstrap/README.md)
- [GitHub Actions CI](docs/GITHUB_ACTIONS.md)
- [Cost & operations](docs/COST_AND_OPS.md)
- [Architecture review](docs/INFRASTRUCTURE_REVIEW.md)

## Contributing

1. Branch from `main`
2. Open PR → Terraform plan runs automatically
3. Merge to `main` triggers plan + apply (configure `production` environment reviewers optional)
