#!/bin/bash

# Quick Fix Script for MeshCentral SSL Issues
echo "🚨 MESHCENTRAL QUICK FIX - SSL Certificate Errors"
echo "================================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${RED}🔥 IMMEDIATE ACTION REQUIRED${NC}"
echo "-----------------------------"

echo "1. 🗑️  DELETE your current MeshCentral service in Coolify"
echo "2. 📋 COPY the config below EXACTLY"
echo "3. ✅ DEPLOY with a different port"
echo ""

echo -e "${BLUE}📋 USE THIS EXACT CONFIG:${NC}"
echo "=========================="
cat << 'EOF'
version: '3.8'

services:
  meshcentral:
    image: typhonragewind/meshcentral:latest
    container_name: jd-meshcentral
    restart: unless-stopped
    ports:
      - "9080:80"
    environment:
      - NODE_ENV=production
    volumes:
      - meshcentral_data:/opt/meshcentral/meshcentral-data
      - meshcentral_userfiles:/opt/meshcentral/meshcentral-files
      - meshcentral_backup:/opt/meshcentral/meshcentral-backup

volumes:
  meshcentral_data:
  meshcentral_userfiles:
  meshcentral_backup:
EOF

echo ""
echo -e "${GREEN}🎯 ACCESS AFTER DEPLOYMENT:${NC}"
echo "=============================="
echo "HTTP: http://jd-fleet-manager.laikadynamics.com:9080"
echo ""

echo -e "${YELLOW}🔧 IF PORT 9080 IS TAKEN, TRY:${NC}"
echo "- Change '9080:80' to '9081:80'"
echo "- Change '9080:80' to '3000:80'"  
echo "- Change '9080:80' to '4000:80'"
echo ""

echo -e "${BLUE}⚡ EMERGENCY ALTERNATIVES:${NC}"
echo "========================="

echo ""
echo "Option A: Try different MeshCentral image:"
echo "  image: ylianst/meshcentral:latest"
echo ""

echo "Option B: Use Tailscale/WireGuard instead:"
echo "  - Install Tailscale on tablets"
echo "  - Direct SSH access"
echo "  - Bypass Android restrictions"
echo ""

echo "Option C: TeamViewer Host permanent install:"
echo "  - Install TeamViewer Host on tablets"  
echo "  - Set up unattended access"
echo "  - No server required"
echo ""

echo -e "${GREEN}🏁 BOTTOM LINE:${NC}"
echo "==============="
echo "Use the simple config above with port 9080."
echo "This eliminates ALL SSL certificate generation."
echo "You can set up HTTPS later via Coolify reverse proxy."
echo ""

echo -e "${RED}⏰ TIME-CRITICAL:${NC}"
echo "Deploy the simple config RIGHT NOW to get basic access!"
echo "We can optimize and add SSL later." 