#!/usr/bin/env bash
# One-time import of existing gamyaboutique GitHub Actions config into Terraform state.
# Requires: terraform init in environments/dev, PAT with Actions read/write on gamyaboutique.
#
# Usage:
#   export TF_VAR_github_token=ghp_...   # or export GITHUB_TOKEN=ghp_...
#   bash scripts/import-github-backend-deploy-config.sh
set -euo pipefail

if [[ -z "${TF_VAR_github_token:-}" && -z "${GITHUB_TOKEN:-}" ]]; then
  echo "Set TF_VAR_github_token or GITHUB_TOKEN (PAT with repo/Actions on gvsharma/gamyaboutique)." >&2
  exit 1
fi

WORKING_DIR="${TF_WORKING_DIR:-environments/dev}"
cd "$(dirname "$0")/.."
cd "$WORKING_DIR"

terraform init -input=false

IMPORTS=(
  'module.github_backend_deploy_config[0].github_actions_variable.deploy_bucket:gamyaboutique:DEPLOY_BUCKET'
  'module.github_backend_deploy_config[0].github_actions_variable.ec2_instance_id:gamyaboutique:EC2_INSTANCE_ID'
  'module.github_backend_deploy_config[0].github_actions_variable.ec2_host:gamyaboutique:EC2_HOST'
  'module.github_backend_deploy_config[0].github_actions_secret.aws_backend_deploy_role_arn:gamyaboutique:AWS_BACKEND_DEPLOY_ROLE_ARN'
)

for entry in "${IMPORTS[@]}"; do
  resource="${entry%%:*}"
  import_id="${entry#*:}"
  if terraform state show "$resource" >/dev/null 2>&1; then
    echo "Already in state: $resource"
  else
    echo "Importing $resource <- $import_id"
    terraform import "$resource" "$import_id"
  fi
done

echo ""
echo "Post-import plan (github resources should not show 'create'):"
terraform plan -var-file=ci.tfvars -no-color | grep -E 'github_actions|github_backend_deploy_config|Plan:' || true

echo ""
echo "Expected values (terraform output):"
terraform output -json backend_deploy_github_setup | python3 -m json.tool
