# ci-deploy-iam

IAM role for GitHub Actions to deploy the Next.js static frontend: `s3 sync` + CloudFront invalidation.

## Usage

```hcl
module "ci_deploy" {
  source = "../../modules/ci-deploy-iam"

  name_prefix                 = "gamya-couture-prod"
  github_repository           = "your-org/gamya-couture-web"
  frontend_bucket_arn         = module.s3.frontend_bucket_arn
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
}
```

## GitHub Actions example

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE_ARN }}
      aws-region: ap-south-1
  - run: aws s3 sync out/ s3://BUCKET --delete
  - run: aws cloudfront create-invalidation --distribution-id ID --paths '/*'
```

Set `create_oidc_provider = false` if the GitHub OIDC provider already exists in the account.
