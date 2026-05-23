locals {
  log_group_nginx_access = "/${var.name_prefix}/nginx/access"
  log_group_nginx_error  = "/${var.name_prefix}/nginx/error"
  log_group_app          = "/${var.name_prefix}/app/spring-boot"
  log_group_docker       = "/${var.name_prefix}/docker"

  user_data = templatefile("${path.module}/user-data.sh", {
    name_prefix            = var.name_prefix
    api_port               = var.api_port
    log_group_nginx_access = local.log_group_nginx_access
    log_group_nginx_error  = local.log_group_nginx_error
    log_group_app          = local.log_group_app
    log_group_docker       = local.log_group_docker
  })
}
