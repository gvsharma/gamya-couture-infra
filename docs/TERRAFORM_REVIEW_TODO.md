# Terraform Code Review — TODO

Action items from the production Terraform review (2026-06-09).  
Check off items as they are completed.

**Overall grade:** B+ (MVP/dev) · C (production readiness)

---

## P0 — Fix before prod apply

- [ ] **Align state bucket region across repo**
  - Bootstrap defaults to `ap-south-1` (`bootstrap/variables.tf`); env backends use `us-east-1` (`environments/*/backend.tf`)
  - Live bucket is in `us-east-1` — update bootstrap defaults, README, and `bootstrap/examples/*.hcl` to match
  - Add validation or `check` block to prevent region drift on fresh bootstrap

- [ ] **Harden RDS for production**
  - File: `modules/rds/main.tf`
  - Today: `backup_retention_period = 0`, `deletion_protection = false`, `skip_final_snapshot = true`
  - Add env-based variables (dev keeps current; prod gets backups, deletion protection, final snapshot)
  - Set `apply_immediately = false` for prod

- [ ] **Disable cost scheduler by default in prod**
  - File: `environments/prod/variables.tf` — `enable_cost_schedule` defaults to `true`
  - Change prod default to `false`; keep scheduler enabled in dev only

- [ ] **Scope GitHub OIDC Terraform role**
  - Files: `bootstrap/variables.tf`, `modules/ci-terraform-iam/main.tf`
  - Change `github_attach_administrator_access` / `attach_administrator_access` default to `false`
  - Attach scoped IAM policy (state bucket + target env resources only)
  - Tighten OIDC `sub` from `repo:org/repo:*` to `ref:refs/heads/main` or GitHub Environment

---

## P1 — High priority

- [ ] **Fix scheduler Lambda IAM Describe permissions**
  - File: `modules/scheduler/iam.tf`
  - `ec2:DescribeInstances` and `rds:DescribeDBInstances` require `resources = ["*"]` (list APIs)
  - Handler uses `describe_db_instances` in wait loop — verify IAM after fix

- [ ] **Add prod CI/CD workflow**
  - Current: `.github/workflows/terraform.yml` applies dev only
  - Add separate prod workflow with `environment: production` approval gate
  - Plan on PR; apply on manual dispatch or tagged release

- [ ] **Remove duplicate `modules/networking`**
  - Exact duplicate of `modules/vpc/` — not referenced by any environment
  - Delete `modules/networking/` or alias to `vpc`; update README if needed

- [ ] **Consolidate dev/prod module pairs (DRY)**
  - `vpc-minimal` + `vpc` → single module with `public_subnet_count` flag
  - `ec2-api` + `ec2` → single module with feature flags (CloudWatch, AMI arch)
  - `security-groups-api` + `security-groups` → single module with `restrict_to_cloudfront` flag

- [ ] **Unify dev DB secrets IAM wiring**
  - Dev: inline policy in `modules/ec2-api/iam.tf`
  - Prod: attaches `module.rds.db_secrets_read_policy_arn`
  - Dev should use the RDS module policy ARN like prod

- [ ] **Document / restrict dev security posture**
  - Dev SG allows HTTP/HTTPS from `0.0.0.0/0` (`security-groups-api`)
  - SSH enabled by default in dev tfvars
  - Document that dev is intentionally open; not a prod security model

- [ ] **Treat Terraform state as secret**
  - DB password stored via `random_password` in state (`modules/rds/secrets.tf`)
  - Ensure state bucket IAM is least-privilege; consider Secrets Manager for prod

---

## P2 — Medium priority (maintainability & scale)

- [ ] **Parameterize nginx `server_name` in user-data**
  - File: `modules/ec2/user-data.sh` — hardcoded `api.gamyacouture.com`, etc.
  - Pass domain list from `environments/prod/locals.tf` via template vars

- [ ] **Fix `domain_name` default ambiguity**
  - File: `environments/prod/variables.tf` — default is `"gamyacouture.com"` but examples use `""`
  - Change default to `""`; require explicit opt-in for Route53/ACM

- [ ] **Reorder prod `main.tf` for readability**
  - `route53_records` references `module.ec2.public_ip` but EC2 is defined later
  - Move EC2/RDS before DNS records or add dependency comment

- [ ] **Add static analysis to CI**
  - Add `tflint --recursive`
  - Add `checkov` or `tfsec`
  - Optional: `terraform test` for module contracts

- [ ] **Improve scheduler Lambda build in CI**
  - Fragile manual zip in workflow vs `archive_file` in module
  - Standardize build step; consider hash-based artifact validation

- [ ] **Fix scheduler output hardcoded times**
  - File: `modules/scheduler/outputs.tf` — outputs say "00:00"/"09:00" regardless of cron expressions
  - Derive from variables or document as examples only

- [ ] **Add scheduler failure alerting**
  - No SNS/alert on Lambda or EventBridge Scheduler failures
  - Add CloudWatch alarm + SNS for prod

- [ ] **Remove unused ACM variable**
  - `modules/acm/variables.tf` — `wait_for_validation` is unused

- [ ] **Add DynamoDB PITR on lock table**
  - File: `bootstrap/dynamodb.tf` — point-in-time recovery disabled

- [ ] **Pin Terraform version constraints consistently**
  - Root envs: `>= 1.9.0`; some modules allow `>= 1.8.0`
  - Align all modules to `>= 1.9.0`

- [ ] **Add environment validation in `global/tags.tf`**
  - Validate `environment in ["dev", "prod", "shared"]`
  - Move `owner` default out of hardcoded `"Venkat"` to tfvars

---

## P3 — Architecture evolution (when scaling)

- [ ] **Implement `modules/alb`**
  - Currently stub only (`outputs.tf` placeholder)
  - Wire ALB; move EC2 to private subnets

- [ ] **Enable HTTPS CloudFront origin**
  - File: `modules/cloudfront/api.tf` — `origin_protocol_policy = "http-only"`
  - Acceptable with CloudFront SG restriction; add ALB/ACM for defense in depth

- [ ] **Add AWS WAF on CloudFront**
  - No WAF on public distributions today

- [ ] **Enable RDS Multi-AZ for prod**
  - File: `modules/rds/main.tf` — `multi_az = false`

- [ ] **Add Route53 health checks on origin-api**
  - File: `modules/route53-records/main.tf` — A record to EIP, no health check

- [ ] **Add S3 access logging**
  - Files: `modules/s3/` — no bucket access logs

- [ ] **Remove unnecessary `s3:PutObjectAcl` from media policy**
  - File: `modules/s3/iam.tf` — not needed with BucketOwnerEnforced

- [ ] **Add `prevent_destroy` on prod EC2**
  - File: `modules/ec2/main.tf`

- [ ] **Document bootstrap local state backup**
  - File: `bootstrap/backend.tf` — local state only; no migration path documented

- [ ] **Document Route53 zone import path**
  - For existing domains at registrar — no import workflow documented

- [ ] **Coordinate OIDC provider creation**
  - Multiple stacks can create GitHub OIDC provider (`bootstrap`, `github-oidc`, `ci-deploy-iam`)
  - Document `create_oidc_provider = false` when already exists

- [ ] **Tighten `ci-deploy-iam` OIDC subjects**
  - Default `repo:org/repo:*` — require `ref:refs/heads/main` for prod deploys

---

## What's already good (no action needed)

- [x] Repo layout: bootstrap → environments → modules
- [x] Remote state: S3 + DynamoDB lock, encryption, separate dev/prod keys
- [x] Bootstrap S3 hardening: versioning, SSE, public access block, TLS-only, deny delete
- [x] Central tagging via `global/tags.tf` + per-resource `ResourcePurpose`
- [x] Prod network: CloudFront prefix list SG, RDS SG-to-SG only
- [x] Secrets: SSM SecureString, password `ignore_changes`
- [x] CloudFront: OAC, managed cache policies, SPA error routing
- [x] Scheduler: Terraform 1.9 `check` blocks, correct stop/start order
- [x] Dev CI: fmt → validate → plan → apply with OIDC
- [x] Cost discipline: no NAT, no ALB, optional scheduler, cheapest SKUs
- [x] EC2: IMDSv2 required, encrypted gp3 volumes, SSM access
- [x] `ci-deploy-iam`: least-privilege S3 + CloudFront invalidation only

---

## Review scores (reference)

| Criterion              | Score | Notes                                      |
|------------------------|-------|--------------------------------------------|
| Structure & modularity | A     | Clean layout, sensible module boundaries   |
| Security               | B-    | Good prod SG/OAC/SSM; weak OIDC defaults   |
| Reliability / DR       | D+    | No RDS backups, no Multi-AZ, single EC2    |
| Maintainability        | B-    | DRY violations across dev/prod modules     |
| Operability            | B+    | Great outputs, scheduler, tagging, docs      |
| CI/CD maturity         | C+    | Dev automated; prod manual; no static analysis |
