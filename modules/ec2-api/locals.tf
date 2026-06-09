locals {
  user_data = templatefile("${path.module}/user-data.sh", {
    name_prefix = var.name_prefix
    api_port    = var.api_port
  })
}
