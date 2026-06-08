#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Gamya Couture API bootstrap: ${name_prefix} ==="

dnf update -y
dnf install -y nginx docker

systemctl enable --now docker
systemctl enable --now nginx

# Placeholder API — replace with your Spring Boot / Node container on port ${api_port}
cat >/etc/nginx/conf.d/gamya-api.conf <<'NGINX'
upstream gamya_api {
    server 127.0.0.1:${api_port};
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

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

echo "=== API host ready — deploy app on port ${api_port} ==="
