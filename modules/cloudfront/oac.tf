resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${var.name_prefix}-s3-oac"
  description                       = "OAC for ${var.name_prefix} private S3 origins"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
