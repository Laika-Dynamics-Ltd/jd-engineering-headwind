#!/bin/bash

# MeshCentral Troubleshooting Script for Coolify
# Run this script to diagnose common deployment issues

echo "🔍 MeshCentral Troubleshooting Script"
echo "====================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  Running as root - some commands may need adjustment"
fi

echo ""
echo "1. 📊 Container Status"
echo "---------------------"
if docker ps | grep -q meshcentral; then
    echo "✅ MeshCentral container is running"
    docker ps | grep meshcentral
else
    echo "❌ MeshCentral container is NOT running"
    echo "Recent container logs:"
    docker logs --tail 20 jd-meshcentral 2>/dev/null || echo "No container named 'jd-meshcentral' found"
fi

echo ""
echo "2. 🌐 Port Usage"
echo "----------------"
echo "Checking common ports..."

for port in 80 443 8080 8443 9080 9443; do
    if ss -tuln | grep -q ":$port "; then
        echo "❌ Port $port is in use:"
        ss -tuln | grep ":$port "
    else
        echo "✅ Port $port is available"
    fi
done

echo ""
echo "3. 🔗 DNS Resolution"
echo "-------------------"
echo "Checking domain resolution..."
if nslookup jd-fleet-manager.laikadynamics.com >/dev/null 2>&1; then
    echo "✅ DNS resolves correctly:"
    nslookup jd-fleet-manager.laikadynamics.com | grep -A2 "Name:"
else
    echo "❌ DNS resolution failed for jd-fleet-manager.laikadynamics.com"
fi

echo ""
echo "4. 🔒 SSL/HTTPS Check"
echo "--------------------"
echo "Checking HTTPS connectivity..."

# Try different URLs
urls=(
    "https://jd-fleet-manager.laikadynamics.com"
    "https://jd-fleet-manager.laikadynamics.com:8443"
    "http://jd-fleet-manager.laikadynamics.com:8080"
)

for url in "${urls[@]}"; do
    if curl -s -I "$url" >/dev/null 2>&1; then
        echo "✅ $url is accessible"
    else
        echo "❌ $url is not accessible"
    fi
done

echo ""
echo "5. 📝 Container Logs (Last 10 lines)"
echo "------------------------------------"
if docker ps | grep -q meshcentral; then
    docker logs --tail 10 jd-meshcentral 2>/dev/null || echo "Could not retrieve logs"
else
    echo "Container not running - cannot retrieve logs"
fi

echo ""
echo "6. 💾 Volume Status"
echo "------------------"
echo "Checking MeshCentral volumes..."
docker volume ls | grep meshcentral || echo "No MeshCentral volumes found"

echo ""
echo "7. 🔥 Firewall Status"
echo "--------------------"
if command -v ufw >/dev/null 2>&1; then
    echo "UFW Status:"
    sudo ufw status 2>/dev/null || echo "Cannot check UFW status (may need sudo)"
else
    echo "UFW not installed or not available"
fi

echo ""
echo "8. 🚀 Quick Fix Suggestions"
echo "----------------------------"

if ! docker ps | grep -q meshcentral; then
    echo "🔧 Container not running - try:"
    echo "   docker-compose up -d"
    echo "   or in Coolify: Redeploy the service"
fi

if ss -tuln | grep -q ":80 \|:443 "; then
    echo "🔧 Port conflicts detected - try:"
    echo "   Use docker-compose-with-ports.yml instead"
    echo "   Or let Coolify handle reverse proxy"
fi

echo ""
echo "9. 📋 Environment Check"
echo "----------------------"
echo "Current working directory: $(pwd)"
echo "Docker version: $(docker --version 2>/dev/null || echo 'Docker not found')"
echo "Docker Compose files available:"
ls -la *.yml 2>/dev/null || echo "No .yml files found in current directory"

echo ""
echo "10. 🆘 Emergency Commands"
echo "------------------------"
echo "If all else fails, try these commands:"
echo ""
echo "# Stop and remove everything:"
echo "docker-compose down -v"
echo ""
echo "# Clean start with port version:"
echo "docker-compose -f docker-compose-with-ports.yml up -d"
echo ""
echo "# Check what's using port 80:"
echo "sudo lsof -i :80"
echo ""
echo "# Check what's using port 443:"
echo "sudo lsof -i :443"

echo ""
echo "🏁 Troubleshooting Complete"
echo "==========================="
echo "If issues persist, check the DEPLOYMENT_GUIDE.md for detailed solutions." 