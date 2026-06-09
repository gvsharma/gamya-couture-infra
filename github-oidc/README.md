# GitHub OIDC for Terraform — **dev only**

Account: **085863558134** | Region: **ap-south-1** | Repo: **gvsharma/gamya-couture-infra**

Creates:

1. OIDC provider — `https://token.actions.githubusercontent.com`
2. IAM role — `GitHubTerraformRole` (tags: `Environment=dev`)
3. Trust — `repo:gvsharma/gamya-couture-infra:*`
4. Policy — `AdministratorAccess` (dev only; scope down before prod)

## Apply

```bash
cd github-oidc
terraform init && terraform apply
terraform output -raw role_arn
```

## GitHub

**Settings → Secrets → Actions → `AWS_ROLE_ARN`**

CI deploys **`environments/dev` only** — not prod.
