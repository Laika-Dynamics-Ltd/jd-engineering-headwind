# 🚀 MeshCentral Deployment Guide for Coolify

## 📋 Prerequisites

- Coolify instance running
- Domain DNS pointing to your server: `jd-fleet-manager.laikadynamics.com`
- Ports 8443 and 8080 available (or use reverse proxy method)

## 🎯 Deployment Methods

### Method 1: Coolify Reverse Proxy (Recommended)

**Best for production - Let Coolify handle SSL and routing**

1. **Create New Service in Coolify:**
   - Service Type: `Docker Compose`
   - Name: `jd-fleet-management`

2. **Use the main docker-compose.yml:**
   ```yaml
   # Copy content from docker-compose.yml
   ```

3. **Configure in Coolify:**
   - **Domain:** `jd-fleet-manager.laikadynamics.com`
   - **Port:** `443` (container internal port)
   - **SSL:** Enable (Let's Encrypt)
   - **Force HTTPS:** Enable

4. **Deploy and Access:**
   - URL: `https://jd-fleet-manager.laikadynamics.com`
   - No port numbers needed!

### Method 2: Direct Port Access (Backup)

**Use this if Method 1 doesn't work**

1. **Use docker-compose-with-ports.yml:**
   ```yaml
   # Copy content from docker-compose-with-ports.yml
   ```

2. **Access URLs:**
   - HTTPS: `https://jd-fleet-manager.laikadynamics.com:8443`
   - HTTP: `http://jd-fleet-manager.laikadynamics.com:8080`

## 🔧 Initial Setup Steps

### 1. First Login
1. Access your MeshCentral URL
2. Create admin account:
   - **Email:** `admin@jdengineering.co.nz`
   - **Password:** Use strong password (8+ chars, mixed case, numbers, symbols)
   - **Organization:** `JD Engineering Ltd`

### 2. Basic Configuration
1. Go to **My Server** → **General**
   - **Server Name:** `JD Engineering Fleet Management`
   - **Organization:** `JD Engineering Ltd`

2. **My Server** → **Security**
   - ✅ **Disable "Allow new accounts"**
   - ✅ **Enable "Session recording"**
   - ✅ **Set password requirements**

### 3. Create Device Groups
1. **My Device Groups** → **Add Group**
   - `Test Tablets`
   - `Electrical Department`
   - `Production Tablets`
   - `Management Tablets`

### 4. Generate Agent Installation
1. Click on device group
2. **Add Agent** → **Android (.apk)**
3. Copy download links for each group

## 📱 Installing on Tablets

### Current Method (TeamViewer)
```bash
# On tablet via TeamViewer session:
# 1. Open browser
# 2. Navigate to: https://jd-fleet-manager.laikadynamics.com
# 3. Click "Add Agent" for appropriate group
# 4. Download APK
# 5. Install (may need to enable "Unknown Sources")
```

### QR Code Method
1. Generate QR codes for each device group
2. Scan QR code on tablet
3. Download and install APK

## 🎨 Customization (Post-Deployment)

### Upload Custom Config
1. Access container: `docker exec -it jd-meshcentral bash`
2. Navigate to: `/opt/meshcentral/meshcentral-data/`
3. Upload the `config.json` file
4. Restart container

### Brand Customization
- Upload logo files to `/opt/meshcentral/meshcentral-data/`
- Update `config.json` with image paths
- Restart service

## 🚨 Troubleshooting

### Port Conflicts
```bash
# Check what's using ports
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
sudo netstat -tulpn | grep :8080
sudo netstat -tulpn | grep :8443
```

### SSL Certificate Issues
- Ensure DNS is properly configured
- Wait 2-3 minutes for certificate generation
- Check logs: `docker logs jd-meshcentral`

### Container Won't Start
```bash
# Check logs
docker logs jd-meshcentral

# Restart container
docker restart jd-meshcentral

# Check port usage
sudo ss -tulpn | grep :8443
```

### Access Issues
1. **Can't reach site:**
   - Check DNS resolution: `nslookup jd-fleet-manager.laikadynamics.com`
   - Check firewall: `sudo ufw status`
   - Verify container is running: `docker ps`

2. **SSL Errors:**
   - Wait for certificate generation (2-3 mins)
   - Check container logs for "Invalid certificate name" errors
   - Verify hostname in environment matches DNS

## 🔍 Health Checks

### Container Status
```bash
# Check if container is running
docker ps | grep meshcentral

# Check container health
docker exec jd-meshcentral ps aux | grep mesh
```

### Service Verification
- [ ] Container starts without errors
- [ ] Web interface accessible
- [ ] SSL certificate valid
- [ ] Admin login works
- [ ] Device groups created
- [ ] Agent download links work

## 📊 Monitoring & Maintenance

### Regular Maintenance
- Weekly: Check device connectivity
- Monthly: Review session recordings
- Quarterly: Update MeshCentral image

### Backup Strategy
- Automatic backups enabled (24h interval)
- Backups stored in: `/opt/meshcentral/meshcentral-backup/`
- Password protected with: `JDEngineering2024!`

### Performance Monitoring
- Monitor container resource usage
- Check for failed connection attempts
- Review session recording storage

## 💰 Service Business Model

### Pricing Structure
- **Setup Fee:** $500 one-time
- **Monthly Fee:** $15/device/month
- **Support:** Included in monthly fee

### Value Proposition
- 24/7 remote access to tablets
- Bypass Android security restrictions
- Professional branded interface
- Session recording for troubleshooting
- Centralized device management

## 🎯 Next Steps

1. **Immediate:** Get MeshCentral running and install on test tablet
2. **Week 1:** Roll out to all JD Engineering tablets
3. **Week 2:** White-label branding and custom dashboard
4. **Month 2:** Package as "Tablet Management as a Service"

## 📞 Support

For issues or questions:
- Check logs first: `docker logs jd-meshcentral`
- Verify network connectivity
- Review this guide for troubleshooting steps

---

**Remember:** This creates a permanent solution for tablet management that bypasses Android 15 restrictions while building a scalable service offering for other customers. 