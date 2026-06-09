# GitHub Actions — Terraform CI/CD (dev only)

Workflow: [`.github/workflows/terraform.yml`](../.github/workflows/terraform.yml)

| Setting | Value |
|---------|--------|
| Environment | **dev** |
| Stack path | `environments/dev` |
| AWS account | `085863558134` |
| Region | `ap-south-1` |
| State key | `infra/dev/terraform.tfstate` |
| Role ARN | `vars.AWS_ROLE_ARN` or secret `AWS_ROLE_ARN` (workflow falls back to `GitHubTerraformRole`) |
| GitHub Environment | `development` (both plan and apply) |

**Prod (`environments/prod`) is not deployed by CI** until you change the workflow.

## Events

| Event | Action |
|-------|--------|
| PR → `main` | Plan only (apply skipped) |
| Push → `main` | Plan + auto-apply dev |
| Manual + `apply=false` | Plan only |
| Manual + `apply=true` (any branch) | Plan + apply dev (requires **development** environment approval) |

## Setup checklist

1. Apply `github-oidc/` → get role ARN  
2. (Optional) **Variables → `AWS_ROLE_ARN`** or secret **`AWS_ROLE_ARN`** — workflow has a safe default ARN  
3. **Environments → `development`** — add **Required reviewers** so apply pauses for your approval  
4. Open PR from feature branch → verify **Terraform / Plan (dev)**  
5. To apply **before merge**: **Actions → Terraform → Run workflow** → select branch → **apply = true** → approve deployment  
6. Or merge to `main` → dev stack applies automatically on push  

## Vercel

After apply:

```bash
cd environments/dev && terraform output api_url
# NEXT_PUBLIC_API_URL=http://<eip>
```
