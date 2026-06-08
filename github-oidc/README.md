# GitHub OIDC for Terraform (standalone)

Creates:

1. **IAM OIDC provider** — `https://token.actions.githubusercontent.com`
2. **IAM role** — `GitHubTerraformRole`
3. **Trust policy** — `repo:gvsharma/gamya-couture-infra:*`
4. **Policy** — `AdministratorAccess` (temporary)

## Apply

```bash
cd github-oidc
cp terraform.tfvars.example terraform.tfvars   # optional — defaults match Gamya Couture
terraform init
terraform plan
terraform apply
```

## Output

```bash
terraform output -raw role_arn
# arn:aws:iam::085863558134:role/GitHubTerraformRole
```

Add to GitHub: **Settings → Secrets → Actions → `AWS_ROLE_ARN`**

## Notes

- Uses **local state** by default. For remote state, add a `backend.tf` block.
- IAM is account-global; `ap-south-1` is the provider region only.
- If OIDC provider already exists: `create_oidc_provider = false` in tfvars.
