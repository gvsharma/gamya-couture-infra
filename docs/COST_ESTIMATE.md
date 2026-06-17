# Monthly AWS cost estimate (MVP — ap-south-1)

Approximate USD. Vercel frontend is **not** billed on AWS. Use the [AWS Pricing Calculator](https://calculator.aws/) for quotes.

## Dev environment (`environments/dev`)

| Resource | SKU | 24/7 | Scheduled (~29 h/week running) |
|----------|-----|------|--------------------------------|
| EC2 API | `t3.micro` | ~$7.50/mo | ~$1.50/mo |
| RDS PostgreSQL | `db.t4g.micro` + 20 GB gp3 | ~$15/mo | ~$3.00/mo compute + ~$2.30 storage |
| Elastic IP | attached | ~$0 | ~$0 |
| VPC / subnets / SG | no NAT | ~$0 | ~$0 |
| SSM parameters | standard | ~$0 | ~$0 |
| Scheduler (Lambda + EventBridge) | 6 rules/week | ~$0.05 | ~$0.05 |

| Scenario | ~USD/mo | ~INR/mo (@83) |
|----------|---------|----------------|
| **24/7 (scheduler disabled)** | **~$25** | **~₹2,075** |
| **Scheduled (recommended)** | **~$7** | **~₹580** |

**Scheduled uptime:** Mon–Fri 06:00–11:00 (5 h × 5); Sat 18:00–00:00 (6 h); Sun 06:00–00:00 (18 h) ≈ 29 h/week (~139 h/mo).

## Prod environment (`environments/prod`) — compute only

Excludes CloudFront/S3/Route53 (domain-dependent). With scheduler + `t4g.micro`:

| Resource | Scheduled ~USD/mo |
|----------|-------------------|
| EC2 `t4g.micro` | ~$1.50 |
| RDS `db.t4g.micro` + 20 GB | ~$5.30 |
| Scheduler | ~$0.05 |

## Vercel frontend

Hosted on Vercel (Hobby/Pro plan) — **$0–20/mo** depending on plan; not part of AWS bill.

## Total MVP stack (dev + Vercel)

| | USD/mo |
|--|--------|
| AWS dev (scheduled) | ~$7 |
| Vercel Hobby | $0 |
| **Total** | **~$7** |

## Cost optimization checklist

- [x] Cheapest RDS instance (`db.t4g.micro`)
- [x] Minimum gp3 storage (20 GB)
- [x] No NAT, ALB, Multi-AZ, backups, PI, log exports
- [x] EC2 + RDS weekly scheduler (IST)
- [x] Standardized cost tags (`CostOptimization`, `AutoShutdown`)
- [ ] Destroy dev when idle: `terraform destroy` in `environments/dev`
