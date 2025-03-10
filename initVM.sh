apt update
apt install -y docker-compose python3.12-venv net-tools

bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

git clone https://github.com/babenychka/point_router_public.git
cd /root/point_router_public/sing-box 
docker-compose up -d
cd /root/point_router_public/sing-box-vless
docker-compose up -d

cd /root/

python3.12 -m venv connectionsLimiter
cd /root/connectionsLimiter
source bin/activate
pip install requests schedule
deactivate
cp /root/point_router_public/connectionsLimiter.py /root/connectionsLimiter/main.py

cat << 'EOF' > /root/connectionsLimiter/run.sh
#!/bin/bash
cd /root/connectionsLimiter
source /root/connectionsLimiter/bin/activate

echo "Starting main.py" >&2
/root/connectionsLimiter/bin/python -u main.py 2>&1
echo "Finished main.py" >&2
echo "Finished main.py" >&2

deactivate
EOF
chmod +x /root/connectionsLimiter/run.sh

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

echo PLEASE get confix x-ui 
