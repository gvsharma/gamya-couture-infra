locals {
  bootstrap_script = templatefile("${path.module}/user-data.sh", {
    name_prefix          = var.name_prefix
    api_port             = var.api_port
    app_path             = var.app_path
    db_endpoint          = var.db_endpoint
    db_name              = var.db_name
    db_username          = var.db_username
    remote_deploy_script = indent(0, chomp(file("${path.module}/files/remote-deploy.sh")))
    systemd_unit         = indent(0, chomp(file("${path.module}/files/gamya-couture-backend.service")))
  })

  # cloud-init ssh_authorized_keys runs before the shell bootstrap on first boot.
  user_data = length(var.ssh_authorized_keys) > 0 ? join("\n", [
    "MIME-Version: 1.0",
    "Content-Type: multipart/mixed; boundary=\"==BOUNDARY==\"",
    "",
    "--==BOUNDARY==",
    "Content-Type: text/cloud-config; charset=\"us-ascii\"",
    "MIME-Version: 1.0",
    "Content-Transfer-Encoding: 7bit",
    "Content-Disposition: attachment; filename=\"cloud-config.txt\"",
    "",
    "#cloud-config",
    trimspace(yamlencode({
      ssh_authorized_keys = var.ssh_authorized_keys
    })),
    "",
    "--==BOUNDARY==",
    "Content-Type: text/x-shellscript; charset=\"us-ascii\"",
    "MIME-Version: 1.0",
    "Content-Transfer-Encoding: 7bit",
    "Content-Disposition: attachment; filename=\"userdata.sh\"",
    "",
    local.bootstrap_script,
    "",
    "--==BOUNDARY==--",
  ]) : local.bootstrap_script
}
