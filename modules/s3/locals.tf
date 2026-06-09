locals {
  frontend_bucket_name = "${var.name_prefix}-frontend-static-site-${var.bucket_suffix}"
  images_bucket_name   = "${var.name_prefix}-product-images-${var.bucket_suffix}"
  videos_bucket_name   = "${var.name_prefix}-product-videos-${var.bucket_suffix}"
}
