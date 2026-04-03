#!/bin/bash

echo "===== INSTALLING 3X-UI ====="

apt update -y
apt install -y curl wget unzip

# Install 3x-ui
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# Stop panel to reconfigure
x-ui stop

# ✅ Railway PORT fix
PORT=${PORT:-8080}

# Update config
sed -i "s/\"port\":.*/\"port\": $PORT,/g" /etc/x-ui/x-ui.json

# Start panel
x-ui start

echo "Panel running on port: $PORT"