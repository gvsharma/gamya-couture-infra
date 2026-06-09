# Monthly AWS cost estimate (MVP — ap-south-1)

Approximate USD. Vercel frontend is **not** billed on AWS. Use the [AWS Pricing Calculator](https://calculator.aws/) for quotes.

## Dev environment (`environments/dev`)

| Resource | SKU | 24/7 | Scheduled (00:00–09:00 off) |
|----------|-----|------|-----------------------------|
| EC2 API | `t3.micro` | ~$7.50/mo | ~$4.70/mo |
| RDS PostgreSQL | `db.t4g.micro` + 20 GB gp3 | ~$15/mo | ~$9.40/mo compute + ~$2.30 storage |
| Elastic IP | attached | ~$0 | ~$0 |
| VPC / subnets / SG | no NAT | ~$0 | ~$0 |
| SSM parameters | standard | ~$0 | ~$0 |
| Scheduler (Lambda + EventBridge) | 2 rules/day | ~$0.05 | ~$0.05 |

| Scenario | ~USD/mo | ~INR/mo (@83) |
|----------|---------|----------------|
| **24/7 (scheduler disabled)** | **~$25** | **~₹2,075** |
| **Scheduled (recommended)** | **~$16** | **~₹1,330** |

**Scheduled uptime:** 15 h/day × 30 days ≈ 450 h/mo (vs 730 h 24/7).

## Prod environment (`environments/prod`) — compute only

Excludes CloudFront/S3/Route53 (domain-dependent). With scheduler + `t4g.micro`:

| Resource | Scheduled ~USD/mo |
|----------|-------------------|
| EC2 `t4g.micro` | ~$4.70 |
| RDS `db.t4g.micro` + 20 GB | ~$11.70 |
| Scheduler | ~$0.05 |

## Vercel frontend

Hosted on Vercel (Hobby/Pro plan) — **$0–20/mo** depending on plan; not part of AWS bill.

## Total MVP stack (dev + Vercel)

| | USD/mo |
|--|--------|
| AWS dev (scheduled) | ~$16 |
| Vercel Hobby | $0 |
| **Total** | **~$16** |

## Cost optimization checklist

- [x] Cheapest RDS instance (`db.t4g.micro`)
- [x] Minimum gp3 storage (20 GB)
- [x] No NAT, ALB, Multi-AZ, backups, PI, log exports
- [x] EC2 + RDS daily scheduler (IST)
- [x] Standardized cost tags (`CostOptimization`, `AutoShutdown`)
- [ ] Destroy dev when idle: `terraform destroy` in `environments/dev`
