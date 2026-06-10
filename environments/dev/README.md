# Dev environment

**Current scope: dev only.** Minimal API stack for the Vercel frontend.

| Resource | Spec |
|----------|------|
| Naming | `gamya-couture-dev-*` |
| VPC | `10.50.0.0/16` (public EC2 + private RDS subnets) |
| EC2 | Amazon Linux 2023, `t3.micro` |
| RDS | PostgreSQL 17, `db.t4g.micro`, 20 GB gp3 (private) |
| Scheduler | EC2+RDS stop 00:00 IST / start 09:00 IST |
| Backend deploy | S3 JAR bucket + GitHub OIDC → SSM (no SSH from runners) |
| Tags | `Owner=Venkat`, `CostOptimization=enabled`, `AutoShutdown=true` |
| State | `s3://gamya-couture-terraform-state/infra/dev/terraform.tfstate` |
| Account | `085863558134` |

## Terraform apply order

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars   # local only
terraform init
terraform plan -var-file=ci.tfvars             # CI uses ci.tfvars
terraform apply -var-file=ci.tfvars
```

Modules apply in dependency order: VPC → security groups → RDS → deploy S3 → EC2 → GitHub deploy IAM → scheduler.

After apply, configure `gamyaboutique` GitHub Actions:

```bash
terraform output -json backend_deploy_github_setup
```

Or auto-sync (requires a PAT with `repo` scope on `gvsharma/gamyaboutique` stored as secret `GAMYABOUTIQUE_GH_TOKEN` on this repo):

```bash
GAMYABOUTIQUE_GH_TOKEN=ghp_... bash ../../scripts/sync-backend-deploy-github-config.sh
```

If deploy fails with SSM `Unknown`/`None`, the backend repo usually has a **stale `EC2_INSTANCE_ID`** after Terraform replaces the EC2 instance — re-run the sync above.

Disable nightly shutdown: `enable_cost_schedule = false` in tfvars.

Monthly cost estimate: [docs/COST_ESTIMATE.md](../../docs/COST_ESTIMATE.md)

## Deploy locally

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform plan && terraform apply
```

## GitHub Actions

CI targets **this directory only**. Prod (`environments/prod`) is not deployed via CI until explicitly enabled.

Secret required: `AWS_ROLE_ARN` (dev Terraform OIDC role).
