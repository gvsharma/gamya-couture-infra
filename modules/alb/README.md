# alb (future)

Reserved for **Application Load Balancer** when the API tier outgrows direct EC2 + CloudFront origin.

## Planned integration

```hcl
module "alb" {
  source = "../../modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_security_group_id]
  target_instance_id = module.ec2.instance_id
}
```

Not wired in `environments/prod` yet — current MVP uses CloudFront → EC2 to avoid ALB cost (~$18/mo).
