# GitHub Actions — Terraform CI/CD

Single workflow: [`.github/workflows/terraform.yml`](../.github/workflows/terraform.yml)

| Event | Behavior |
|-------|----------|
| **PR → `main`** | `fmt` → `init` → `validate` → `plan` (no apply) |
| **Push → `main`** | Same plan job, then `apply -auto-approve` |
| **Manual dispatch** | Plan only, or plan + apply when `apply=true` on `main` |

Uses **GitHub OIDC** — no AWS access keys.

---

## Setup

### 1. AWS — GitHub OIDC role (bootstrap)

```bash
cd bootstrap
# terraform.tfvars:
#   enable_github_actions = true
#   github_repository   = "gvsharma/gamya-couture-infra"
terraform apply
terraform output -raw github_terraform_role_arn
```

### 2. GitHub secret (required)

**Settings → Secrets and variables → Actions → Secrets**

| Secret | Value |
|--------|--------|
| `AWS_ROLE_ARN` | IAM role ARN from bootstrap |

### 3. GitHub Environment (optional)

**Settings → Environments → `production`**

Add **required reviewers** to gate the apply job (Pro on private repos, free on public).

### 4. Branch protection (recommended)

Require status check **Terraform / Plan** before merging PRs.

---

## Workflow details

- **Region:** `ap-south-1`
- **Stack:** `environments/prod`
- **Vars file:** `ci.tfvars`
- **Backend:** embedded in `environments/prod/backend.tf`
- **Caching:** Terraform plugin + `.terraform` directory
- **Permissions:** `id-token: write`, `contents: read`

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Could not assume role` | Check `AWS_ROLE_ARN` secret and `github_repository` in bootstrap |
| Plan check failing on PR | Fix `terraform fmt`, `validate`, or plan errors in the log |
| Apply skipped | Only runs on **push to main** or manual dispatch with `apply=true` |
| State lock | Wait for other run to finish |

---

## Security

- Protect `main` with branch protection
- Do not commit `terraform.tfvars` or AWS keys
- Apply uses the plan artifact from the same workflow run
