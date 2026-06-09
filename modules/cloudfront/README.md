# cloudfront

Cost-optimized **CloudFront** distribution for:

- **Next.js static export** (default behavior → frontend bucket)
- **Product images** (`/images/*` → images bucket)
- **Product videos** (`/videos/*` → videos bucket)

All S3 origins are **private**; access is **OAC-only** with **HTTPS redirect** for viewers.

## Features

| Feature | Implementation |
|---------|----------------|
| Private S3 | Origin Access Control (SigV4) + bucket policies |
| HTTPS only | `viewer_protocol_policy = redirect-to-https` |
| Low cost | `PriceClass_100` (India/Europe/US edge) |
| SPA routing | 403/404 → `index.html` |
| Image-ready | `/images/*` forwards **Accept** header (future resizing/AVIF) |
| Compression | Brotli/gzip via `compress = true` |

## Image optimization (next steps)

This module is **ready** for:

1. **CloudFront Functions** — URL rewrite (`/images/width=400/...`)
2. **Lambda@Edge** — on-the-fly resize
3. **AWS Data Transfer** — store derivatives in the images bucket under `/images/`

Enable `enable_image_optimization_headers = true` (default) so `Accept` reaches the origin when you add optimizers.

## URL layout

| Path | Origin |
|------|--------|
| `https://<cf-domain>/` | Frontend static site |
| `https://<cf-domain>/images/...` | Product images bucket |
| `https://<cf-domain>/videos/...` | Product videos bucket |

Upload images to S3 key `images/product-1.jpg` (note prefix matches behavior path).

## Custom domains

| Distribution | Aliases | Origin |
|--------------|---------|--------|
| **Web** | `gamyacouture.com`, `www.gamyacouture.com` | S3 frontend |
| **API** | `api.gamyacouture.com`, `admin.gamyacouture.com` | `origin-api.*` → EC2:80 |

```hcl
aliases                 = ["gamyacouture.com", "www.gamyacouture.com"]
acm_certificate_arn     = module.acm.certificate_arn_validated
enable_api_distribution = true
api_aliases             = ["api.gamyacouture.com", "admin.gamyacouture.com"]
api_origin_hostname     = "origin-api.gamyacouture.com"
```

API distribution uses **CachingDisabled** and forwards all viewer headers to Spring Boot.

## Deploy frontend

```bash
aws s3 sync ./out s3://BUCKET_ID --delete
aws cloudfront create-invalidation --distribution-id DIST_ID --paths "/*"
```

## Bucket policies

Created in this module (`bucket_policies.tf`) so the distribution ARN is known—avoids Terraform cycles with `modules/s3`.

## Cost

~$0–3/month at ~500 hits/day with PriceClass_100 (data transfer + requests).
