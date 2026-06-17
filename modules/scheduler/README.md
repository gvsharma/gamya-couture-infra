# scheduler

Weekly **EC2 + RDS stop/start** for MVP cost savings using **EventBridge Scheduler** (timezone-aware) and a small **Lambda** (128 MB).

## Schedule (IST / `Asia/Kolkata`)

| Day | Running window | Start rule | Stop rule |
|-----|----------------|------------|-----------|
| **Mon–Fri** | 06:00–11:00 (5 h) | `cron(0 6 ? * MON-FRI *)` | `cron(0 11 ? * MON-FRI *)` |
| **Saturday** | 18:00–00:00 (6 h) | `cron(0 18 ? * SAT *)` | `cron(0 0 ? * SUN *)` |
| **Sunday** | 06:00–00:00 (18 h) | `cron(0 6 ? * SUN *)` | `cron(0 0 ? * MON *)` |

Six EventBridge Scheduler rules (3 start + 3 stop). Storage (gp3) still bills while RDS exists.

## Dependency order

| Action | Order |
|--------|-------|
| **Stop** | EC2 → RDS |
| **Start** | RDS → wait until `available` → EC2 |

## Architecture

```
EventBridge Scheduler (Asia/Kolkata)
        │  {"action":"stop"|"start"}
        ▼
   Lambda (python3.12, 128 MB)
        │  ec2:Stop/StartInstances
        │  rds:Stop/StartDBInstance
        ▼
   Target EC2 + RDS instances
```

## IAM (least privilege)

| Role | Permissions |
|------|-------------|
| **Lambda** | `Describe/Stop/Start` on **one** EC2 ARN and/or **one** RDS ARN; logs only to pre-created log group |
| **Scheduler** | `lambda:InvokeFunction` on this function only |

## Usage

```hcl
module "scheduler" {
  source = "../../modules/scheduler"

  name_prefix            = "gamya-couture-dev"
  db_instance_identifier = module.rds.db_instance_id
  ec2_instance_id        = module.ec2.instance_id

  timezone = "Asia/Kolkata"
  enabled  = var.enable_cost_schedule

  # Optional: override built-in weekly defaults
  # start_schedules = { ... }
  # stop_schedules  = { ... }
}
```

## Inputs

| Name | Default | Description |
|------|---------|-------------|
| `timezone` | `Asia/Kolkata` | IANA timezone for cron |
| `start_schedules` | Built-in Mon–Sun windows | Map of start rules (empty = defaults) |
| `stop_schedules` | Built-in Mon–Sun windows | Map of stop rules (empty = defaults) |
| `enabled` | `true` | Create schedules |
| `ec2_instance_id` | `""` | Skip EC2 when empty |
| `db_instance_identifier` | `""` | Skip RDS when empty |
| `log_retention_days` | `3` | Lambda log retention |

## Disable scheduling

Set `enable_cost_schedule = false` in environment tfvars. Lambda/IAM remain; EventBridge rules are not created. `AutoShutdown` tag becomes `false` via provider defaults.

## Operational notes

1. **API impact:** EC2 and RDS are down outside the weekly windows above. Vercel frontend still serves static pages; API returns errors until the next start rule fires.
2. **Logs:** CloudWatch `/aws/lambda/<name-prefix>-cost-scheduler`
3. **Manual override (Terraform-managed resources only):**
   ```bash
   aws ec2 start-instances --instance-ids <id>
   aws rds start-db-instance --db-instance-identifier <id>
   ```

## Cost

| Component | ~USD/mo |
|-----------|---------|
| EventBridge Scheduler | ~$0 (6 weekly rules) |
| Lambda (6 invocations/day max) | ~$0 |
| CloudWatch Logs (3d) | ~$0.05 |

Savings come from **EC2 + RDS compute** while stopped.

## Files

| File | Purpose |
|------|---------|
| `lambda/handler.py` | Stop/start logic with dependency ordering |
| `locals.tf` | Default start/stop cron expressions |
| `schedules.tf` | EventBridge Scheduler rules |
| `iam.tf` | Lambda + Scheduler roles |
| `lambda.tf` | Function + log group |
| `checks.tf` | Validate targets and ARNs |
