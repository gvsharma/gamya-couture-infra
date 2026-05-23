# route53-records

DNS records for **gamyacouture.com** after ACM and CloudFront exist.

## Records

| Hostname | Target | Purpose |
|----------|--------|---------|
| `gamyacouture.com` | Web CloudFront | Apex storefront |
| `www.gamyacouture.com` | Web CloudFront | WWW storefront |
| `origin-api.gamyacouture.com` | EC2 Elastic IP (A) | CloudFront custom origin |
| `api.gamyacouture.com` | API CloudFront | Spring Boot API (HTTPS) |
| `admin.gamyacouture.com` | API CloudFront | Admin / CRM (HTTPS) |

## Why `origin-api`?

CloudFront needs a stable **domain name** origin pointing at EC2. Public clients use `api` / `admin` hostnames on CloudFront with ACM TLS; CloudFront forwards to `origin-api` over HTTP port 80.

Configure nginx on EC2 with `server_name` for api, admin, and origin-api hostnames.

## Apply order

1. `modules/route53` (zone)
2. `modules/acm` (validation records)
3. `modules/cloudfront` (with ACM ARN)
4. **`modules/route53-records`** (this module)
