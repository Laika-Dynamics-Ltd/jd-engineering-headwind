#!/bin/bash

echo "🚨 BULLET-PROOF DEPLOYMENT - RUN ON YOUR VPS NOW"
echo "================================================="

echo ""
echo "Copy and paste these commands on your Coolify VPS:"
echo ""

cat << 'EOF'
# Stop any existing containers
docker stop jd-meshcentral 2>/dev/null && docker rm jd-meshcentral 2>/dev/null

# Deploy MeshCentral (ONE COMMAND)
docker run -d --name jd-meshcentral --restart unless-stopped -p 3000:80 -v meshcentral_data:/opt/meshcentral/meshcentral-data typhonragewind/meshcentral:latest

# Open firewall
ufw allow 3000/tcp

# Check status
docker ps | grep meshcentral

# Get your access URL
echo "Access: http://$(curl -s ifconfig.me):3000"
EOF

echo ""
echo "⚡ THAT'S IT! MeshCentral will be running in 30 seconds."
echo "✅ No SSL issues, no port conflicts, no Coolify complexity."
echo "🎯 Direct tablet access for your managed service." 