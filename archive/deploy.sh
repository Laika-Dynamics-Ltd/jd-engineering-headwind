#!/bin/bash

# MeshCentral Deployment Script for Coolify
# This script helps deploy MeshCentral with proper SSL configuration

echo "🚀 MeshCentral Coolify Deployment Helper"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}🔍 Step 1: Checking Prerequisites${NC}"
echo "-----------------------------------"

# Check if we're in the right directory
if [ ! -f "docker-compose-fixed.yml" ]; then
    echo -e "${RED}❌ docker-compose-fixed.yml not found!${NC}"
    echo "Please run this script from the project directory."
    exit 1
fi

echo -e "${GREEN}✅ Configuration files found${NC}"

echo ""
echo -e "${BLUE}🛠️  Step 2: Deployment Instructions${NC}"
echo "------------------------------------"

echo "The Coolify CLI doesn't support direct deployment, so follow these steps:"
echo ""

echo -e "${YELLOW}1. Delete your current MeshCentral service in Coolify UI${NC}"
echo "   - Go to your Coolify dashboard"
echo "   - Find the existing MeshCentral service"
echo "   - Delete it completely"
echo ""

echo -e "${YELLOW}2. Create new service with fixed configuration:${NC}"
echo "   - Service Type: Docker Compose"
echo "   - Name: jd-fleet-management"
echo ""

echo -e "${YELLOW}3. Copy the fixed docker-compose configuration:${NC}"
echo "   - Use the contents of: docker-compose-fixed.yml"
echo "   - This configuration disables internal SSL completely"
echo ""

echo -e "${YELLOW}4. Configure in Coolify UI:${NC}"
echo "   - Domain: jd-fleet-manager.laikadynamics.com"
echo "   - Port: 80 (container internal port)"
echo "   - SSL: ✅ Enable (Let's Encrypt)"
echo "   - Force HTTPS: ✅ Enable"
echo ""

echo -e "${YELLOW}5. Deploy and test:${NC}"
echo "   - Click Deploy"
echo "   - Wait 2-3 minutes for deployment"
echo "   - Access: https://jd-fleet-manager.laikadynamics.com"
echo ""

echo -e "${BLUE}🔧 Step 3: Key Fixes in This Configuration${NC}"
echo "--------------------------------------------"

echo -e "${GREEN}✅ Fixed SSL Issues:${NC}"
echo "   - WEB_TLS=false (disables internal SSL)"
echo "   - USE_HTTPS=false (forces HTTP mode)"
echo "   - CERT='' (no certificate generation)"
echo "   - ARGS=--cert none (explicitly disables certificates)"
echo ""

echo -e "${GREEN}✅ Proper Reverse Proxy Setup:${NC}"
echo "   - REVERSE_PROXY=true"
echo "   - Only exposes port 80 internally"
echo "   - Lets Coolify handle all SSL termination"
echo ""

echo -e "${BLUE}🚨 If You Still Get SSL Errors${NC}"
echo "--------------------------------"

echo "1. Check container logs:"
echo "   docker logs jd-meshcentral"
echo ""

echo "2. Run the troubleshoot script:"
echo "   ./troubleshoot.sh"
echo ""

echo "3. Verify DNS resolution:"
echo "   nslookup jd-fleet-manager.laikadynamics.com"
echo ""

echo -e "${BLUE}📋 What This Deployment Gives You${NC}"
echo "-----------------------------------"

echo -e "${GREEN}✅ Immediate Benefits:${NC}"
echo "   - Permanent remote access to all tablets"
echo "   - Bypass Android 15 security restrictions"
echo "   - Professional JD Engineering branding"
echo "   - Session recording for troubleshooting"
echo "   - Centralized device management"
echo ""

echo -e "${GREEN}💰 Business Opportunity:${NC}"
echo "   - Setup Fee: \$500 one-time"
echo "   - Monthly Fee: \$15/device/month"
echo "   - For 20 tablets: \$300/month recurring revenue"
echo ""

echo -e "${BLUE}🎯 Next Steps After Deployment${NC}"
echo "----------------------------"

echo "1. ✅ Create admin account"
echo "2. ✅ Set up device groups"
echo "3. ✅ Install agents on tablets via TeamViewer"
echo "4. ✅ Test remote access"
echo "5. ✅ Apply custom branding"
echo ""

echo -e "${GREEN}🏁 Ready to Deploy!${NC}"
echo "======================"
echo ""
echo "Go to your Coolify dashboard and follow the steps above."
echo "The docker-compose-fixed.yml configuration should eliminate all SSL certificate errors."
echo ""
echo -e "${YELLOW}Need help? Check DEPLOYMENT_GUIDE.md for detailed troubleshooting.${NC}" 