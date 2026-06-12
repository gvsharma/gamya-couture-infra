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
| Product media | Private S3 `gamya-couture-dev-media` + CloudFront CDN (OAC) |
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

Modules apply in dependency order: VPC → security groups → RDS → deploy S3 → product media CDN → EC2 → GitHub deploy IAM → scheduler.

After apply, sync product image URLs:

```bash
terraform output product_media_ec2_env_hint
terraform output product_media_vercel_env_hint
```

Set `APP_STORAGE_S3_PUBLIC_BASE_URL` on EC2 and `NEXT_PUBLIC_IMAGE_CDN_HOST` on Vercel to the CloudFront domain.

After apply, configure `gamyaboutique` GitHub Actions:

```bash
terraform output -json backend_deploy_github_setup
```

**Auto-sync (recommended):** store a PAT with `repo` scope on `gvsharma/gamyaboutique` as secret `GAMYABOUTIQUE_GH_TOKEN` on this repo. Terraform apply then updates gamyaboutique Actions variables/secrets via the `github-backend-deploy-config` module.

Manual fallback:

```bash
GAMYABOUTIQUE_GH_TOKEN=ghp_... bash ../../scripts/sync-backend-deploy-github-config.sh
```

Or local apply with token: `TF_VAR_github_token=ghp_... terraform apply -var-file=ci.tfvars`

`EC2_HOST` is the **Elastic IP** (`module.ec2-api`); it stays stable across stop/start. Backend deploy also resolves the instance by tag `gamya-couture-dev-api` if `EC2_INSTANCE_ID` is stale.

**First apply with Terraform-managed GitHub config:** if variables already exist on gamyaboutique, import once before apply:

```bash
terraform import 'module.github_backend_deploy_config[0].github_actions_variable.deploy_bucket' gamyaboutique:DEPLOY_BUCKET
terraform import 'module.github_backend_deploy_config[0].github_actions_variable.ec2_instance_id' gamyaboutique:EC2_INSTANCE_ID
terraform import 'module.github_backend_deploy_config[0].github_actions_variable.ec2_host' gamyaboutique:EC2_HOST
terraform import 'module.github_backend_deploy_config[0].github_actions_secret.aws_backend_deploy_role_arn' gamyaboutique:AWS_BACKEND_DEPLOY_ROLE_ARN
```

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
