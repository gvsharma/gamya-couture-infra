# acm

**ACM certificate in `us-east-1`** (required for CloudFront) with **DNS validation** in Route53.

## Certificate coverage

| Name | Example |
|------|---------|
| Apex | `gamyacouture.com` |
| WWW | `www.gamyacouture.com` |
| API | `api.gamyacouture.com` |
| Admin | `admin.gamyacouture.com` |

## Usage

Must use the **us-east-1** provider alias:

```hcl
module "acm" {
  source = "../../modules/acm"
  providers = {
    aws = aws.us_east_1
  }

  domain_name               = "gamyacouture.com"
  subject_alternative_names = [
    "www.gamyacouture.com",
    "api.gamyacouture.com",
    "admin.gamyacouture.com",
  ]
  route53_zone_id = module.route53.zone_id
}
```

## Outputs

| Output | Use |
|--------|-----|
| `certificate_arn_validated` | Attach to CloudFront `viewer_certificate` |
| `validation_record_fqdns` | Troubleshoot DNS validation |

## HTTPS

CloudFront terminates TLS with this certificate for **www/apex** and **api/admin** distributions.

Origin (EC2) uses HTTP on port 80 from CloudFront only — no certificate required on the instance.

## Cost

ACM public certificates are **free**.
