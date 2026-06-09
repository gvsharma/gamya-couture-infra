# Bootstrap — Terraform Remote State

One-time infrastructure to host Terraform state for **Gamya Couture** in **ap-south-1 (Mumbai)**.

| Resource | Name | Purpose |
|----------|------|---------|
| S3 bucket | `gamya-couture-terraform-state` | Versioned, encrypted state storage |
| DynamoDB | `terraform-locks` | State locking (pay-per-request) |
| IAM policy | `gamya-couture-terraform-state-access` | Least-privilege operator access |

**Cost:** Typically &lt; ₹100/month at low apply frequency (S3 storage + occasional DynamoDB lock writes).

## Safety controls

- S3 **versioning** — recover overwritten state objects
- **SSE-S3 (AES256)** + bucket key — encryption at rest (no KMS monthly cost)
- **Public access blocked** — bucket not internet-readable
- **TLS-only** bucket policy — deny insecure transport
- **Deny `s3:DeleteBucket`** — extra guard against bucket removal
- Terraform **`prevent_destroy`** on bucket and lock table
- **`force_destroy = false`** on the bucket

## Folder layout

```
bootstrap/
├── README.md
├── backend.tf              # local state for bootstrap only
├── versions.tf
├── variables.tf
├── s3.tf
├── dynamodb.tf
├── iam.tf
├── outputs.tf
├── terraform.tfvars.example
└── examples/
    ├── backend.prod.hcl
    └── backend.dev.hcl
```

## Prerequisites

- AWS CLI configured with permissions to create S3, DynamoDB, and IAM policies
- Terraform ≥ 1.8
- S3 bucket name `gamya-couture-terraform-state` must be **globally unique** (change in `terraform.tfvars` if taken)

## Deployment commands

### 1. Bootstrap (local state)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# edit if bucket name must change

terraform init
terraform plan
terraform apply
```

Save outputs:

```bash
terraform output
```

### 2. Attach IAM policy to your Terraform principal

```bash
# IAM user example (replace USER_NAME)
aws iam attach-user-policy \
  --user-name USER_NAME \
  --policy-arn "$(terraform output -raw terraform_state_iam_policy_arn)"

# IAM role example (replace ROLE_NAME)
aws iam attach-role-policy \
  --role-name ROLE_NAME \
  --policy-arn "$(terraform output -raw terraform_state_iam_policy_arn)"
```

### 3. Migrate `environments/prod` to remote state

```bash
cd ../environments/prod

# Ensure backend.tf contains the s3 backend block (see backend.tf.example in this env)

terraform init -backend-config=../../bootstrap/examples/backend.prod.hcl

# If you have existing local state from Phase 1:
terraform init -migrate-state -backend-config=../../bootstrap/examples/backend.prod.hcl
```

Repeat for `dev` with `backend.dev.hcl`.

### 4. Verify

```bash
aws s3 ls s3://gamya-couture-terraform-state/
aws dynamodb describe-table --table-name terraform-locks --region ap-south-1
```

## Backend configuration (environments)

Use a **partial backend** in each environment:

**`environments/prod/backend.tf`:**

```hcl
terraform {
  backend "s3" {}
}
```

**Init with config file (recommended):**

```bash
terraform init -backend-config=../../bootstrap/examples/backend.prod.hcl
```

Or copy values from `terraform output backend_config_prod` after bootstrap.

## State key layout

| Environment | State key |
|-------------|-----------|
| prod | `infra/terraform.tfstate` |
| dev | `infra/dev/terraform.tfstate` |

Single bucket, isolated keys — no cross-environment state bleed.

## Destroy policy

**Do not destroy** bootstrap in normal operations. If you must retire the stack:

1. Remove `prevent_destroy` from `s3.tf` and `dynamodb.tf` temporarily
2. Remove or adjust the bucket policy `DenyBucketDeletion` statement
3. Empty versioned objects manually if required
4. Only then `terraform destroy`

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Bucket name already exists | Set `state_bucket_name` to a unique name in `terraform.tfvars` |
| AccessDenied on init | Attach `terraform_state_iam_policy_arn` to your IAM principal |
| Error acquiring state lock | Check DynamoDB table exists; clear stale lock row only if sure no apply is running |

## GitHub Actions (optional)

Set `enable_github_actions = true` and `github_repository` in `terraform.tfvars`, then re-apply bootstrap to create an OIDC IAM role for CI.

```bash
terraform output -raw github_terraform_role_arn
```

Add that ARN as GitHub repository secret `AWS_ROLE_ARN`. See [docs/GITHUB_ACTIONS.md](../docs/GITHUB_ACTIONS.md).

## What this does not create

No VPC, EC2, RDS, or application resources — remote state only.
