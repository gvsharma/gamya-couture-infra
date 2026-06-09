# scheduler

Daily **RDS stop/start** to reduce cost using **EventBridge Scheduler** (timezone-aware) and a small **Lambda** function.

## Schedule (IST)

| Action | Local time | Default cron | Timezone |
|--------|------------|--------------|----------|
| **Stop** | 12:00 AM | `cron(0 0 * * ? *)` | `Asia/Kolkata` |
| **Start** | 7:00 AM | `cron(0 7 * * ? *)` | `Asia/Kolkata` |

RDS is stopped ~7 hours per day (~29% compute savings). Storage is still billed.

## Architecture

```
EventBridge Scheduler (Asia/Kolkata)
        │  {"action":"stop"|"start"}
        ▼
   Lambda (python3.12, 128 MB)
        │  rds:StopDBInstance / StartDBInstance
        ▼
   Target RDS instance
```

## IAM (least privilege)

| Role | Permissions |
|------|-------------|
| **Lambda** | `Describe/Stop/Start` on **one** DB ARN; logs only to pre-created log group |
| **Scheduler** | `lambda:InvokeFunction` on this function only |

## Usage

```hcl
module "scheduler" {
  source = "../../modules/scheduler"

  name_prefix            = "gamya-couture-prod"
  db_instance_identifier = module.rds.db_instance_id
  db_instance_arn        = module.rds.db_instance_arn
  enabled                = var.enable_rds_schedule
}
```

## Inputs

| Name | Default | Description |
|------|---------|-------------|
| `timezone` | `Asia/Kolkata` | IANA timezone for cron |
| `stop_schedule_expression` | `cron(0 0 * * ? *)` | Midnight stop |
| `start_schedule_expression` | `cron(0 7 * * ? *)` | 7 AM start |
| `enabled` | `true` | Create schedules |
| `log_retention_days` | `4` | Lambda log retention |

## Lambda payload

```json
{ "action": "stop" }
{ "action": "start" }
```

## Operational notes

1. **API impact:** DB is unavailable 00:00–07:00 IST; Spring Boot should handle connection errors or use a maintenance banner.
2. **First deploy:** If RDS is running at midnight, stop runs automatically; verify in CloudWatch Logs `/aws/lambda/<name-prefix>-rds-scheduler`.
3. **Manual override:**
   ```bash
   aws rds start-db-instance --db-instance-identifier <id>
   aws rds stop-db-instance --db-instance-identifier <id>
   ```
4. **Dev:** set `enabled = false` in `environments/dev` when `enable_rds_schedule = false`.

## Cost

| Component | ~USD/mo |
|-----------|---------|
| EventBridge Scheduler | ~$0 (within free tier for 2 daily rules) |
| Lambda (2 invocations/day) | ~$0 |
| CloudWatch Logs (4d) | ~$0.10 |

Savings come from **RDS compute** while stopped (~$3–4 USD/month vs 24/7 micro).

## Files

| File | Purpose |
|------|---------|
| `lambda/handler.py` | Stop/start logic |
| `schedules.tf` | EventBridge Scheduler rules |
| `iam.tf` | Lambda + Scheduler roles |
| `lambda.tf` | Function + log group |
