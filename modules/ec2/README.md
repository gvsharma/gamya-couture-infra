# ec2

Single **ARM (Graviton)** application host for Gamya Couture: Amazon Linux 2023, Docker, Docker Compose, nginx reverse proxy, Java 21, SSM, Elastic IP, and CloudWatch Logs (4-day retention).

No Auto Scaling, ECS, or load balancer.

## Architecture

```
Internet → Elastic IP → EC2 (public subnet)
                           ├── nginx :80 / :443 → Spring Boot :8080 (Docker)
                           ├── SSM Session Manager
                           └── CloudWatch agent → log groups (4d retention)
```

## What user-data installs

| Component | Package / action |
|-----------|------------------|
| OS | Amazon Linux 2023 **aarch64** (latest AMI) |
| Docker | `docker` + `docker-compose-plugin` |
| Java | `java-21-amazon-corretto-headless` |
| Proxy | `nginx` → `127.0.0.1:8080` |
| Observability | `amazon-cloudwatch-agent` |
| Layout | `/opt/gamya-couture/{app,config,logs,data}` |

## IAM

| Attachment | Purpose |
|------------|---------|
| `AmazonSSMManagedInstanceCore` | SSM access (no bastion required) |
| `CloudWatchAgentServerPolicy` | Agent metrics/logs |
| Custom inline policy | Write to this module’s log groups |

Attach extra policies via `additional_iam_policy_arns` (e.g. S3 media bucket).

## Usage

```hcl
module "ec2" {
  source = "../../modules/ec2"

  name_prefix          = "gamya-couture-prod"
  environment          = "prod"
  subnet_id            = module.networking.public_subnet_ids[0]
  security_group_ids   = [module.security_groups.ec2_security_group_id]
  instance_type        = "t4g.small"
  key_name             = var.ec2_key_name # optional
  additional_iam_policy_arns = []
}
```

## Inputs

| Name | Default | Description |
|------|---------|-------------|
| `instance_type` | `t4g.small` | Graviton instance size |
| `api_port` | `8080` | Spring Boot upstream port |
| `log_retention_days` | `4` | CloudWatch log retention |
| `root_volume_size_gb` | `30` | gp3 root volume |
| `key_name` | `null` | SSH key pair (optional) |
| `ami_id` | latest AL2023 ARM | AMI override |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | EC2 ID (SSM target) |
| `public_ip` | **Elastic IP** for Route53 API record |
| `private_ip` | VPC private IP |
| `iam_role_arn` | Instance role |
| `cloudwatch_log_group_names` | Log group map |
| `deployment_paths` | Host paths for CI/CD |

## After apply

1. **SSM shell:** `aws ssm start-session --target <instance_id>`
2. **Deploy API:** copy `docker-compose.yml` / image to `/opt/gamya-couture/app`, set `/opt/gamya-couture/config/app.env`, run:
   ```bash
   cd /opt/gamya-couture/app && docker compose up -d
   ```
3. **Logs:** Spring Boot should append to `/opt/gamya-couture/logs/app/spring-boot.log` or configure Docker logging to `/opt/gamya-couture/logs/docker/containers.log`.
4. **DNS:** Point `api.example.com` A record to `public_ip`.

## HTTPS

Security group allows 443; terminate TLS on nginx later (ACM import or Certbot). User-data configures HTTP on port 80 only.

## Cost

~$12–15 USD/month for `t4g.small` + small gp3 volume + Elastic IP (free when attached).
