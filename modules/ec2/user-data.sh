#!/bin/bash
set -euxo pipefail

NAME_PREFIX="${name_prefix}"
API_PORT="${api_port}"
LOG_NGINX_ACCESS="${log_group_nginx_access}"
LOG_NGINX_ERROR="${log_group_nginx_error}"
LOG_APP="${log_group_app}"
LOG_DOCKER="${log_group_docker}"

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Gamya Couture EC2 bootstrap: $NAME_PREFIX ==="

# --- Packages: Docker, Compose plugin, nginx, Java 21 ---
dnf update -y
dnf install -y \
  docker \
  docker-compose-plugin \
  nginx \
  java-21-amazon-corretto-headless \
  amazon-cloudwatch-agent \
  jq

systemctl enable --now docker
usermod -aG docker ec2-user

java -version

# --- Deployment layout ---
install -d -m 0755 /opt/gamya-couture/{app,config,logs,data}
install -d -m 0755 /opt/gamya-couture/logs/{nginx,app,docker}
chown -R ec2-user:ec2-user /opt/gamya-couture

cat >/opt/gamya-couture/app/docker-compose.yml <<'COMPOSE'
# Placeholder — deploy your Spring Boot image here.
# Example:
# services:
#   api:
#     image: your-registry/gamya-api:latest
#     ports:
#       - "127.0.0.1:8080:8080"
#     env_file:
#       - /opt/gamya-couture/config/app.env
#     restart: unless-stopped
services: {}
COMPOSE

touch /opt/gamya-couture/config/app.env
chmod 0600 /opt/gamya-couture/config/app.env
chown ec2-user:ec2-user /opt/gamya-couture/app/docker-compose.yml /opt/gamya-couture/config/app.env

# --- nginx reverse proxy → Spring Boot on localhost ---
cat >/etc/nginx/conf.d/gamya-couture.conf <<NGINX
upstream gamya_spring_boot {
    server 127.0.0.1:${api_port};
    keepalive 32;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _ api.gamyacouture.com admin.gamyacouture.com origin-api.gamyacouture.com;

    access_log /opt/gamya-couture/logs/nginx/access.log;
    error_log  /opt/gamya-couture/logs/nginx/error.log warn;

    location /health {
        access_log off;
        return 200 'ok';
        add_header Content-Type text/plain;
    }

    location / {
        proxy_pass http://gamya_spring_boot;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Connection "";
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
NGINX

# Remove default server conflict on AL2023 if present
rm -f /etc/nginx/conf.d/default.conf 2>/dev/null || true

nginx -t
systemctl enable --now nginx

# --- CloudWatch agent (4-day retention set on log groups in Terraform) ---
cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CW
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/gamya-couture/logs/nginx/access.log",
            "log_group_name": "$LOG_NGINX_ACCESS",
            "log_stream_name": "{instance_id}/access",
            "timezone": "UTC"
          },
          {
            "file_path": "/opt/gamya-couture/logs/nginx/error.log",
            "log_group_name": "$LOG_NGINX_ERROR",
            "log_stream_name": "{instance_id}/error",
            "timezone": "UTC"
          },
          {
            "file_path": "/opt/gamya-couture/logs/app/spring-boot.log",
            "log_group_name": "$LOG_APP",
            "log_stream_name": "{instance_id}/app",
            "timezone": "UTC"
          },
          {
            "file_path": "/opt/gamya-couture/logs/docker/containers.log",
            "log_group_name": "$LOG_DOCKER",
            "log_stream_name": "{instance_id}/docker",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CW

touch /opt/gamya-couture/logs/app/spring-boot.log
touch /opt/gamya-couture/logs/docker/containers.log
chown -R ec2-user:ec2-user /opt/gamya-couture/logs

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

echo "=== Bootstrap complete ==="
