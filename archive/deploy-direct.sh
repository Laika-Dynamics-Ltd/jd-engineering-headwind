#!/bin/bash

# Direct VPS Deployment Commands for MeshCentral
# Run these commands on your Coolify VPS server

echo "🚀 DIRECT VPS DEPLOYMENT - MeshCentral Fleet Management"
echo "======================================================"

echo ""
echo "📋 RUN THESE COMMANDS ON YOUR COOLIFY VPS SERVER:"
echo "=================================================="

cat << 'EOF'

# 1. SSH into your Coolify VPS server
ssh root@your-server-ip

# 2. Stop any existing MeshCentral containers
docker stop jd-meshcentral 2>/dev/null || true
docker rm jd-meshcentral 2>/dev/null || true

# 3. Create deployment directory
mkdir -p /opt/jd-meshcentral
cd /opt/jd-meshcentral

# 4. Create docker-compose.yml file
cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  meshcentral:
    image: typhonragewind/meshcentral:latest
    container_name: jd-meshcentral
    restart: unless-stopped
    ports:
      - "3000:80"
    environment:
      - NODE_ENV=production
    volumes:
      - meshcentral_data:/opt/meshcentral/meshcentral-data
      - meshcentral_userfiles:/opt/meshcentral/meshcentral-files
      - meshcentral_backup:/opt/meshcentral/meshcentral-backup
    networks:
      - jd-fleet

volumes:
  meshcentral_data:
  meshcentral_userfiles:
  meshcentral_backup:

networks:
  jd-fleet:
    driver: bridge
COMPOSE_EOF

# 5. Start MeshCentral
docker-compose up -d

# 6. Check if it's running
docker-compose ps
docker-compose logs

# 7. Set up Nginx reverse proxy (optional - for HTTPS)
cat > /etc/nginx/sites-available/jd-fleet << 'NGINX_EOF'
server {
    listen 80;
    server_name jd-fleet-manager.laikadynamics.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_EOF

# 8. Enable the site (if nginx is installed)
ln -s /etc/nginx/sites-available/jd-fleet /etc/nginx/sites-enabled/ 2>/dev/null || echo "Nginx not found, skipping"
systemctl reload nginx 2>/dev/null || echo "Nginx not running, skipping"

# 9. Open firewall ports
ufw allow 3000/tcp 2>/dev/null || echo "UFW not found, skipping"
ufw allow 80/tcp 2>/dev/null || echo "UFW not found, skipping"

# 10. Check final status
echo "✅ MeshCentral should now be running!"
echo "Access via: http://your-server-ip:3000"
echo "Or: http://jd-fleet-manager.laikadynamics.com (if DNS points to server)"

EOF

echo ""
echo "🔥 ALTERNATIVE: ONE-LINER DEPLOYMENT"
echo "===================================="

cat << 'EOF'

# Ultra-quick deployment (single command):
ssh root@your-server-ip 'docker run -d --name jd-meshcentral --restart unless-stopped -p 3000:80 -v meshcentral_data:/opt/meshcentral/meshcentral-data typhonragewind/meshcentral:latest'

EOF

echo ""
echo "📱 IMMEDIATE ACCESS AFTER DEPLOYMENT:"
echo "====================================="
echo "• HTTP: http://your-server-ip:3000"
echo "• Create admin account: admin@jdengineering.co.nz"
echo "• Add device groups: Test Tablets, Production Tablets"
echo "• Download APK for each group"
echo "• Install on tablets via TeamViewer"
echo ""

echo "🎯 BUSINESS READY:"
echo "=================="
echo "• Setup Fee: \$500 one-time"
echo "• Monthly: \$15/device/month"
echo "• 20 tablets = \$300/month recurring"
echo "• Bypass Android 15 restrictions"
echo "• Professional remote access solution" 