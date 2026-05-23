# route53 (hosted zone)

Creates the public **Route53 hosted zone** for your root domain.

## Delegation

After apply, set your registrar nameservers to `name_servers` output:

```bash
terraform output name_servers
```

## DNS records

Application records (apex, www, api, admin, origin) are in **`modules/route53-records`**, applied after ACM and CloudFront to avoid Terraform module cycles.
