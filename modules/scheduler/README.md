# scheduler

Daily **EC2 + RDS stop/start** for MVP cost savings using **EventBridge Scheduler** (timezone-aware) and a small **Lambda** (128 MB).

## Schedule (IST)

| Action | Local time | Default cron | Timezone |
|--------|------------|--------------|----------|
| **Stop** | 12:00 AM | `cron(0 0 * * ? *)` | `Asia/Kolkata` |
| **Start** | 9:00 AM | `cron(0 9 * * ? *)` | `Asia/Kolkata` |

Resources run ~15 hours/day (~62.5% compute savings on EC2 + RDS). Storage (gp3) still bills while RDS exists.

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
  db_instance_arn        = module.rds.db_instance_arn
  ec2_instance_id        = module.ec2.instance_id
  ec2_instance_arn       = module.ec2.instance_arn

  timezone                  = "Asia/Kolkata"
  stop_schedule_expression  = "cron(0 0 * * ? *)"
  start_schedule_expression = "cron(0 9 * * ? *)"
  enabled                   = var.enable_cost_schedule
}
```

## Inputs

| Name | Default | Description |
|------|---------|-------------|
| `timezone` | `Asia/Kolkata` | IANA timezone for cron |
| `stop_schedule_expression` | `cron(0 0 * * ? *)` | Midnight stop |
| `start_schedule_expression` | `cron(0 9 * * ? *)` | 9 AM start |
| `enabled` | `true` | Create schedules |
| `ec2_instance_id` | `""` | Skip EC2 when empty |
| `db_instance_identifier` | `""` | Skip RDS when empty |
| `log_retention_days` | `3` | Lambda log retention |

## Disable scheduling

Set `enable_cost_schedule = false` in environment tfvars. Lambda/IAM remain; EventBridge rules are not created. `AutoShutdown` tag becomes `false` via provider defaults.

## Operational notes

1. **API impact:** EC2 and RDS are down 00:00–09:00 IST. Vercel frontend still serves static pages; API returns errors until 09:00.
2. **Logs:** CloudWatch `/aws/lambda/<name-prefix>-cost-scheduler`
3. **Manual override (Terraform-managed resources only):**
   ```bash
   aws ec2 start-instances --instance-ids <id>
   aws rds start-db-instance --db-instance-identifier <id>
   ```

## Cost

| Component | ~USD/mo |
|-----------|---------|
| EventBridge Scheduler | ~$0 (2 daily rules) |
| Lambda (2 invocations/day) | ~$0 |
| CloudWatch Logs (3d) | ~$0.05 |

Savings come from **EC2 + RDS compute** while stopped.

## Files

| File | Purpose |
|------|---------|
| `lambda/handler.py` | Stop/start logic with dependency ordering |
| `schedules.tf` | EventBridge Scheduler rules |
| `iam.tf` | Lambda + Scheduler roles |
| `lambda.tf` | Function + log group |
| `checks.tf` | Validate targets and ARNs |
