# Production environment

**Not deployed via GitHub Actions yet.** CI currently targets `environments/dev` only.

Deploy prod manually when ready:

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform plan && terraform apply
```

State key: `infra/terraform.tfstate`
