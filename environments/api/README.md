# API environment (minimal)

Minimal deployable stack for **Gamya Couture backend APIs** consumed by a **Vercel** frontend.

## Resources

| Resource | Spec |
|----------|------|
| VPC | `10.50.0.0/16` (default) |
| Subnet | 1 public subnet + IGW |
| EC2 | Amazon Linux 2023, `t3.micro` |
| SG | SSH restricted (`admin_cidr`), HTTP/HTTPS open |
| Access | Elastic IP, SSM Session Manager |

## Deploy

```bash
cd environments/api
cp terraform.tfvars.example terraform.tfvars
# Edit admin_cidr with your IP/32

terraform init
terraform plan
terraform apply
```

## Vercel integration

After apply:

```bash
terraform output api_url
# Set in Vercel: NEXT_PUBLIC_API_URL=http://<eip>
```

Use HTTPS in production (add ACM + ALB or CloudFront later).

## Cost

~$8–10 USD/month (`t3.micro` + 8 GB gp3 + EIP when attached).
