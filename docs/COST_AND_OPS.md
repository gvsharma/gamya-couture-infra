# Cost & Operations

All lifecycle changes go through Terraform — no routine AWS Console edits.

## Weekly compute schedule (IST / Asia/Kolkata)

| Action | Time (IST) | Days | Resources | Implementation |
|--------|------------|------|-----------|----------------|
| **Start** | 06:00 | Mon–Fri | RDS (wait) → EC2 | EventBridge Scheduler → Lambda |
| **Stop** | 11:00 | Mon–Fri | EC2 → RDS | EventBridge Scheduler → Lambda |
| **Start** | 18:00 | Saturday | RDS (wait) → EC2 | EventBridge Scheduler → Lambda |
| **Stop** | 00:00 | Sunday (midnight) | EC2 → RDS | EventBridge Scheduler → Lambda |
| **Start** | 06:00 | Sunday | RDS (wait) → EC2 | EventBridge Scheduler → Lambda |
| **Stop** | 00:00 | Monday (midnight) | EC2 → RDS | EventBridge Scheduler → Lambda |

**Running windows:** Mon–Fri 06:00–11:00; Sat 18:00–00:00; Sun 06:00–00:00 IST.

Controlled by `enable_cost_schedule` in environment tfvars. Defaults are built into `modules/scheduler/locals.tf`; override per environment:

```hcl
enable_cost_schedule = true
schedule_timezone    = "Asia/Kolkata"
# schedule_start_overrides = {}  # empty = module defaults
# schedule_stop_overrides  = {}
```

Disable for 24/7 operation: `enable_cost_schedule = false`

## Cost levers

1. **Scheduler** — EC2 + RDS off ~83% of the week (~29 h running of 168 h).
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

## Module apply order

1. `vpc-minimal`
2. `security-groups` / `security-groups-api`
3. `rds`
4. `backend-deploy-s3` (optional)
5. `product-media-cdn` (optional)
6. `ec2` / `ec2-api`
7. `ci-backend-deploy-iam` (optional)
8. `github-backend-deploy-config` (optional)
9. `scheduler` (needs EC2 + RDS IDs)

## Manual start (outside schedule)

```bash
aws ec2 start-instances --instance-ids <id> --region ap-south-1
aws rds start-db-instance --db-instance-identifier <id> --region ap-south-1
```

Wait for RDS `available` before relying on the API.
