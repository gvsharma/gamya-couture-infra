# GitHub Actions — Terraform CI/CD (dev only)

Workflow: [`.github/workflows/terraform.yml`](../.github/workflows/terraform.yml)

| Setting | Value |
|---------|--------|
| Environment | **dev** |
| Stack path | `environments/dev` |
| AWS account | `085863558134` |
| Region | `ap-south-1` |
| State key | `infra/dev/terraform.tfstate` |
| Secret | `AWS_ROLE_ARN` |
| GitHub Environment | `development` |

**Prod (`environments/prod`) is not deployed by CI** until you change the workflow.

## Events

| Event | Action |
|-------|--------|
| PR → `main` | Plan dev only |
| Push → `main` | Plan + apply dev |
| Manual + `apply=false` | Plan only |

## Setup checklist

1. Apply `github-oidc/` → get role ARN  
2. GitHub secret **`AWS_ROLE_ARN`**  
3. (Optional) **Environments → `development`** — required reviewers  
4. Open PR from feature branch → verify **Terraform / Plan (dev)**  
5. Merge to `main` → dev stack applies  

## Vercel

After apply:

```bash
cd environments/dev && terraform output api_url
# NEXT_PUBLIC_API_URL=http://<eip>
```
