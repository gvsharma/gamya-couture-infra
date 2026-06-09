# rds

Cheapest production-viable **PostgreSQL 16** on **RDS `db.t4g.micro`** with **20 GB gp3**, private subnets, credentials in **SSM Parameter Store**, and **4-day** log retention.

## Configuration summary

| Setting | Value |
|---------|--------|
| Engine | PostgreSQL **16** |
| Instance | **db.t4g.micro** (Graviton) |
| Storage | **20 GB gp3**, encrypted |
| Network | Private subnets, **no** public access |
| Security | Caller-provided SG (EC2 → 5432 only) |
| Backups | **0 days** (no automated snapshots) |
| Deletion protection | **Off** |
| Multi-AZ | **Off** |
| Performance Insights | **Off** |
| Enhanced monitoring | **Off** |

## Secrets (Parameter Store)

| Parameter | Path |
|-----------|------|
| Username | `{parameter_store_prefix}/username` |
| Password | `{parameter_store_prefix}/password` (random 32 chars) |

Both use **SecureString** (default AWS managed KMS key — no CMK hourly cost).

Password is generated with `random_password`, applied to RDS, and written to SSM. `lifecycle.ignore_changes` on the password parameter and RDS password prevents accidental rotation on every apply.

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"

  name_prefix            = "gamya-couture-prod"
  private_subnet_ids     = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.security_groups.rds_security_group_id]
  db_name                = "gamya"
  db_username            = "gamya_admin"
  parameter_store_prefix = "/gamya-couture/prod/db"
}
```

Attach `db_secrets_read_policy_arn` to the EC2 instance role.

## Outputs

| Output | Use |
|--------|-----|
| `db_endpoint` / `db_port` | Spring `spring.datasource.url` |
| `jdbc_url` | JDBC connection string (password from SSM) |
| `ssm_parameter_*_name` | App/bootstrap scripts |
| `db_secrets_read_policy_arn` | EC2 IAM attachment |

## Spring Boot example

```properties
spring.datasource.url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
# Load user/password from SSM at startup (AWS SDK) or inject via deploy script:
# aws ssm get-parameter --name /gamya-couture/prod/db/password --with-decryption
```

## Monthly cost estimate (ap-south-1)

Prices are approximate USD; use the [AWS Pricing Calculator](https://calculator.aws/) for quotes.

| Component | Calculation | ~USD/mo |
|-----------|-------------|---------|
| **db.t4g.micro** | ~$0.018/hr × 730 h | **~13.00** |
| **gp3 20 GB** | ~$0.115/GB-month | **~2.30** |
| **Backup storage** | 0 (retention 0) | **0** |
| **Performance Insights** | Disabled | **0** |
| **Enhanced monitoring** | Disabled | **0** |
| **CloudWatch Logs** | Low volume, 4-day retention | **~0.50** |
| **SSM parameters** | Standard parameters | **~0** |

| Scenario | ~USD/mo | ~INR/mo (@83) |
|----------|---------|----------------|
| **24/7 running** | **~16** | **~₹1,330** |
| **Stop 7 h/day (scheduler)** | **~12** compute + storage | **~₹1,000** |

Storage is billed while the instance exists, even when stopped.

**Not included:** NAT, data transfer, application EC2.

## Downstream

- **scheduler** module — stop/start `db_instance_id` on IST cron
- **ec2** — attach `db_secrets_read_policy_arn`; set `DB_HOST` from `db_endpoint`

## Security notes

- Never commit passwords; use SSM only.
- To rotate password: taint `random_password.master`, update SSM and RDS manually in a maintenance window.
- For production hardening later: enable `backup_retention_period`, `deletion_protection`, and Multi-AZ (adds cost).
