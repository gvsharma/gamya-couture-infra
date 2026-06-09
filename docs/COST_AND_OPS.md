# Cost & Operations

All lifecycle changes go through Terraform — no routine AWS Console edits.

## Daily compute schedule (IST)

| Action | Time (IST) | Resources | Implementation |
|--------|------------|-----------|----------------|
| **Stop** | 00:00 | EC2 → RDS | EventBridge Scheduler → Lambda |
| **Start** | 09:00 | RDS (wait) → EC2 | EventBridge Scheduler → Lambda |

Controlled by `enable_cost_schedule` in environment tfvars. Override per environment:

```hcl
schedule_stop_expression  = "cron(0 0 * * ? *)"
schedule_start_expression = "cron(0 9 * * ? *)"
schedule_timezone         = "Asia/Kolkata"
```

Disable for 24/7 operation: `enable_cost_schedule = false`

## Cost levers

1. **Scheduler** — EC2 + RDS off 9 hours/night (~38% compute hours saved).
2. **Cheapest SKUs** — dev `t3.micro` EC2 + `db.t4g.micro` RDS; prod `t4g.micro` EC2.
3. **No NAT** — EC2 in public subnet with tight SG; RDS private, SG-to-SG only.
4. **No paid RDS features** — no Multi-AZ, backups, Performance Insights, log exports.
5. **gp3 minimum storage** — 20 GB RDS, 8 GB EC2 root (dev).
6. **CloudFront Price Class 100** (prod) — India + edge only.

## Tagging governance

All resources inherit via `provider default_tags`:

| Tag | Value |
|-----|-------|
| `Project` | `gamya-couture` |
| `Environment` | `dev` / `prod` |
| `ManagedBy` | `terraform` |
| `Owner` | `Venkat` |
| `CostOptimization` | `enabled` |
| `AutoShutdown` | `true` / `false` (matches scheduler) |

Per-resource `ResourcePurpose` tags are set in modules (e.g. `compute-api-backend-ec2`).

## Security operations

- **SSH:** restricted to `var.admin_cidr` when `enable_ssh = true`; prefer SSM Session Manager.
- **Secrets:** DB credentials in SSM Parameter Store (SecureString).
- **Destroy:** `terraform destroy` in `environments/dev` or `environments/prod` removes all managed resources.

## What we deliberately do not run

NAT Gateway (~$32/mo), ALB (~$18/mo), ECS, Aurora, automated RDS snapshots, Performance Insights.

## Terraform apply order

```bash
cd environments/dev   # or environments/prod
terraform init
terraform plan -var-file=ci.tfvars    # or terraform.tfvars locally
terraform apply -var-file=ci.tfvars
```

Module dependency order (automatic via Terraform graph):

1. `vpc` / `vpc-minimal`
2. `security_groups`
3. `rds` (subnet group → instance → SSM secrets)
4. `ec2` (needs RDS IAM policy ARN)
5. `scheduler` (needs EC2 + RDS IDs/ARNs)

See [COST_ESTIMATE.md](./COST_ESTIMATE.md) for monthly bill projections.
