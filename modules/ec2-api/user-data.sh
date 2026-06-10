#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Gamya Couture API bootstrap: ${name_prefix} ==="

APP_PATH="${app_path}"
SERVICE_NAME="gamya-couture-backend"

dnf update -y
dnf install -y nginx docker amazon-ssm-agent java-21-amazon-corretto-headless awscli

systemctl enable --now amazon-ssm-agent
systemctl enable --now docker
systemctl enable --now nginx

if ! id gamya >/dev/null 2>&1; then
  useradd --system --home-dir "$${APP_PATH}" --shell /sbin/nologin gamya
fi

mkdir -p "$${APP_PATH}"/{app,backup,incoming,config,logs,scripts}
chown -R gamya:gamya "$${APP_PATH}"
chmod 750 "$${APP_PATH}"
chmod 750 "$${APP_PATH}/config" "$${APP_PATH}/app" "$${APP_PATH}/backup" "$${APP_PATH}/logs"
chmod 775 "$${APP_PATH}/incoming" "$${APP_PATH}/scripts"

cat >"$${APP_PATH}/scripts/remote-deploy.sh" <<'REMOTE_DEPLOY_EOF'
${remote_deploy_script}
REMOTE_DEPLOY_EOF
chmod 755 "$${APP_PATH}/scripts/remote-deploy.sh"

cat >"/etc/systemd/system/$${SERVICE_NAME}.service" <<'SYSTEMD_EOF'
${systemd_unit}
SYSTEMD_EOF

if [[ ! -f "$${APP_PATH}/config/application.env" ]]; then
  cat >"$${APP_PATH}/config/application.env" <<ENV_EOF
# Managed by Terraform bootstrap — set DB_PASSWORD and JWT_SECRET before first deploy.
SPRING_PROFILES_ACTIVE=dev
SERVER_PORT=${api_port}
DB_URL=jdbc:postgresql://${db_endpoint}:5432/${db_name}
DB_USER=${db_username}
DB_PASSWORD=CHANGE_ME
JWT_SECRET=CHANGE_ME_MIN_32_CHARS
CORS_ALLOWED_ORIGINS=https://gamyaboutique.vercel.app,http://localhost:3000
ENV_EOF
  chmod 640 "$${APP_PATH}/config/application.env"
  chown root:gamya "$${APP_PATH}/config/application.env"
fi

systemctl daemon-reload
systemctl enable "$${SERVICE_NAME}"

# Placeholder API — nginx proxies :80 → Spring Boot on :${api_port}
cat >/etc/nginx/conf.d/gamya-api.conf <<'NGINX'
upstream gamya_api {
    server 127.0.0.1:${api_port};
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    client_max_body_size 15M;

    location /health {
        access_log off;
        return 200 'ok';
        add_header Content-Type text/plain;
    }

    location / {
        proxy_pass http://gamya_api;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

rm -f /etc/nginx/conf.d/default.conf 2>/dev/null || true
nginx -t
systemctl restart nginx

echo "=== API host ready — SSM deploy via $${APP_PATH}/scripts/remote-deploy.sh ==="
