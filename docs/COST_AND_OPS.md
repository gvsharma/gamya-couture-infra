# Cost & Operations

## Daily RDS schedule (IST)

| Action | Time (IST) | Implementation |
|--------|------------|----------------|
| Stop | 00:00 | EventBridge → Lambda → `StopDBInstance` |
| Start | 07:00 | EventBridge → Lambda → `StartDBInstance` |

App tier (EC2) stays up; expect DB connection errors during the stopped window unless the app handles them gracefully.

## Cost levers

1. **Stop dev RDS overnight** — use `environments/dev` with `enable_rds_schedule = false` or destroy dev when idle.
2. **CloudWatch** — log retention capped at 4 days in `modules/cloudwatch`.
3. **No NAT** — EC2 in public subnet with tight SG; RDS only reachable from app SG.
4. **CloudFront Price Class 100** — India + edge locations only (cheapest).
5. **EC2** — `t4g.micro`; upgrade only after metrics justify it.

## Security operations

- **SSH:** `modules/security` allows port 22 only from `var.admin_cidr`.
- **Shell access:** prefer `aws ssm start-session --target <instance-id>`.
- **Secrets:** DB password in SSM Parameter Store (SecureString), not in Terraform state plaintext when Phase 4+ lands.

## Monitoring (minimal)

- EC2 status check failed
- RDS CPU > 80% (when running)
- CloudFront 5xx rate (optional, Phase 10)

## What we deliberately do not run

NAT Gateway (~$32/mo), ALB (~$18/mo), ECS control plane, Aurora, automated RDS snapshots (per MVP spec).
