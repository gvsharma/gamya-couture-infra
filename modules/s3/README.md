# s3

Three **private** S3 buckets for Gamya Couture with encryption, lifecycle cost controls, and IAM for EC2 media uploads. **Public reads** are only via CloudFront (bucket policies in `modules/cloudfront`).

## Buckets

| Bucket | Purpose |
|--------|---------|
| `{prefix}-frontend-static-site-{account}` | Next.js static export |
| `{prefix}-product-images-{account}` | Product images |
| `{prefix}-product-videos-{account}` | Product videos |

## Security

- Block all public access
- SSE-S3 (AES256)
- Bucket owner enforced
- No public ACLs

## Lifecycle (low cost)

| Bucket | Rules |
|--------|--------|
| **Frontend** | Abort incomplete MPU after 7d; expire noncurrent versions after 30d |
| **Images** | Abort incomplete MPU; optional IA transition (default off) |
| **Videos** | Abort incomplete MPU; **STANDARD_IA after 90 days** |

## EC2 uploads

`ec2_media_upload_policy_arn` grants `PutObject` / `GetObject` on **images** and **videos** only (not frontend — use CI/deploy role separately).

## Usage

```hcl
data "aws_caller_identity" "current" {}

module "s3" {
  source = "../../modules/s3"

  name_prefix   = "gamya-couture-prod"
  bucket_suffix = data.aws_caller_identity.current.account_id
}
```

Wire CloudFront bucket policies after `module.cloudfront` is applied (see `cloudfront` module).

## Deploy static site

```bash
aws s3 sync out/ s3://$(terraform output -raw frontend_bucket_id) --delete
# Invalidate CloudFront cache after deploy (see cloudfront outputs)
```
