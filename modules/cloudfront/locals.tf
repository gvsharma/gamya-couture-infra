locals {
  use_custom_domain = var.acm_certificate_arn != null && length(var.aliases) > 0

  # AWS managed policies (stable IDs)
  cache_policy_caching_disabled    = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  cache_policy_caching_optimized   = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  origin_request_policy_cors_s3    = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  origin_request_policy_all_viewer = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  response_headers_policy_cors     = "5cc9a04a-26e2-4a45-9731-1e07c4e50b8e"

  media_origin_request_policy_id = var.enable_image_optimization_headers ? local.origin_request_policy_all_viewer : local.origin_request_policy_cors_s3
}
