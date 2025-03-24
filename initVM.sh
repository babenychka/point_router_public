#!/bin/bash

apt update
apt install -y docker-compose python3.12-venv net-tools

wget https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh
/bin/bash install.sh
rm install.sh

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl start docker

git clone https://github.com/babenychka/point_router_public.git
cd /root/point_router_public/sing-box 
docker-compose up -d
cd /root/point_router_public/sing-box-vless
docker-compose up -d

cd /root/point_router_public/
# закинуть проект в гитхаб и не ебать себе мозги, просто пулить и все
# python3.12 -m venv connectionsLimiter
# cd /root/connectionsLimiter
# source bin/activate
# pip install requests schedule
# deactivate

chmod +x /root/point_router_public/connectionsLimiter/run.sh

cat << 'EOF' > /etc/systemd/system/connectionsLimiter.service
[Unit]
Description=Connections Limiter Service
After=network.target

[Service]
Type=simple
ExecStart=/root/point_router_public/connectionsLimiter/run.sh
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

apt install nginx
sed -i '/server_name _;/a\
        location \/hc\/ {\
                return 200 "OK";\
        }' /etc/nginx/sites-enabled/default
nginx -t && nginx -s reload


echo PLEASE get confix x-ui 
