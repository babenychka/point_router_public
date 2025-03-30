#!/bin/bash

apt update
apt install -y docker-compose python3.12-venv net-tools

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl restart docker
rm get-docker.sh

mkdir -p /sing-box-prod
echo "version: '3.8'

services:
  sing-box:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: sing-box
    ports:
      - "443:443" 
    volumes:
     - ./config:/etc/sing-box/
    command: -D /var/lib/sing-box -C /etc/sing-box/ run
    restart: always
" | tee /root/sing-box-prod/docker-compose.yml 
echo "# Use a lightweight base image
FROM ghcr.io/sagernet/sing-box

# Download and install sing-box

# Create configuration directory
RUN mkdir -p /etc/sing-box

# Copy the configuration file into the container

# Expose the default port
EXPOSE 443

# Command to run the application
#CMD ["sing-box", "run", "-c", "/etc/sing-box/config.json"]
" | tee /root/sing-box-prod/Dockerfile



cd /root/sing-box-prod
docker-compose build
docker-compose up -d
chmod +x /root/point_router_public/connectionsLimiter/run.sh

python3.12 -m venv /root/connectionsLimiter
cp /root/point_router_public/connectionsLimiter/connectionsLimiter.py /root/connectionsLimiter
cp /root/point_router_public/connectionsLimiter/run.sh /root/connectionsLimiter
/root/connectionsLimiter/bin/pip install requests schedule

cat << 'EOF' > /etc/systemd/system/connectionsLimiter.service
[Unit]
Description=Connections Limiter Service
After=network.target

[Service]
Type=simple
ExecStart=/root/connectionsLimiter/run.sh
Restart=on-failure
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable connectionsLimiter.service
systemctl start connectionsLimiter.service

# install and configure nginx hc srv
apt install nginx -y
sed -i '/server_name _;/a\
        location \/hc\/ {\
                return 200 "OK";\
        }' /etc/nginx/sites-enabled/default
nginx -t && nginx -s reload

wget https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh
/bin/bash install.sh
rm install.sh

echo Done
echo 
echo PLEASE get confix x-ui 
