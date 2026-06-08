# Dev environment

**Current scope: dev only.** Minimal API stack for the Vercel frontend.

| Resource | Spec |
|----------|------|
| Naming | `gamya-couture-dev-*` |
| VPC | `10.50.0.0/16` |
| EC2 | Amazon Linux 2023, `t3.micro` |
| State | `s3://gamya-couture-terraform-state/infra/dev/terraform.tfstate` |
| Account | `085863558134` |

## Deploy locally

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform plan && terraform apply
```

## GitHub Actions

CI targets **this directory only**. Prod (`environments/prod`) is not deployed via CI until explicitly enabled.

Secret required: `AWS_ROLE_ARN` (dev Terraform OIDC role).
