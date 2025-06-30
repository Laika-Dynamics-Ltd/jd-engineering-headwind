# ⚡ QUICK START - MeshCentral on Coolify

## 🚨 IMMEDIATE ACTION (Fix Your Current Issue)

### Step 1: Delete Current Failed Service
1. In Coolify dashboard
2. Find your current MeshCentral service
3. **Delete it completely** (it's stuck on port conflicts)

### Step 2: Deploy Method 1 (Recommended)

**Copy this EXACT config to Coolify:**

```yaml
version: '3.8'

services:
  meshcentral:
    image: typhonragewind/meshcentral:latest
    container_name: jd-meshcentral
    restart: unless-stopped
    expose:
      - "443"
      - "80"
    environment:
      - HOSTNAME=jd-fleet-manager.laikadynamics.com
      - REVERSE_PROXY=true
      - REVERSE_PROXY_TLS_PORT=443
      - IFRAME=false
      - ALLOW_NEW_ACCOUNTS=false
      - SESSION_RECORDING=true
      - WEB_TLS=false
      - AGENT_PORT=80
      - AGENT_ALIASPORT=443
    volumes:
      - meshcentral_data:/opt/meshcentral/meshcentral-data
      - meshcentral_userfiles:/opt/meshcentral/meshcentral-files
      - meshcentral_backup:/opt/meshcentral/meshcentral-backup

volumes:
  meshcentral_data:
  meshcentral_userfiles:
  meshcentral_backup:
```

**Coolify Settings:**
- **Domain:** `jd-fleet-manager.laikadynamics.com`
- **Port:** `443`
- **SSL:** ✅ Enable
- **Force HTTPS:** ✅ Enable

### Step 3: If Method 1 Fails

**Use this config instead:**

```yaml
version: '3.8'

services:
  meshcentral:
    image: typhonragewind/meshcentral:latest
    container_name: jd-meshcentral
    restart: unless-stopped
    ports:
      - "8443:443"
      - "8080:80"
    environment:
      - HOSTNAME=jd-fleet-manager.laikadynamics.com
      - REVERSE_PROXY=false
      - IFRAME=false
      - ALLOW_NEW_ACCOUNTS=false
      - SESSION_RECORDING=true
    volumes:
      - meshcentral_data:/opt/meshcentral/meshcentral-data
      - meshcentral_userfiles:/opt/meshcentral/meshcentral-files
      - meshcentral_backup:/opt/meshcentral/meshcentral-backup

volumes:
  meshcentral_data:
  meshcentral_userfiles:
  meshcentral_backup:
```

**Access:** `https://jd-fleet-manager.laikadynamics.com:8443`

## 🎯 First 5 Minutes After Deployment

1. **Access the site** (wait 2-3 mins for SSL)
2. **Create admin account:**
   - Email: `admin@jdengineering.co.nz`
   - Password: Strong password (8+ chars)
   - Organization: `JD Engineering Ltd`

3. **Quick setup:**
   - Go to **My Server** → **General**
   - Server Name: `JD Engineering Fleet Management`
   - **My Server** → **Security** → Disable "Allow new accounts"

4. **Create device group:**
   - **My Device Groups** → **Add Group**
   - Name: `Test Tablets`

5. **Get agent link:**
   - Click `Test Tablets` group
   - **Add Agent** → **Android (.apk)**
   - Copy the download URL

## 📱 Install on Tablet RIGHT NOW

**Via your current TeamViewer session:**

1. Open browser on tablet
2. Navigate to: `https://jd-fleet-manager.laikadynamics.com` (or `:8443` if using Method 2)
3. Click the APK download link from step 5 above
4. Install APK (enable "Unknown Sources" if needed)
5. Open MeshCentral Agent app
6. Tablet should appear in your dashboard immediately

## ✅ Success Indicators

- [ ] Container starts without port errors
- [ ] Web interface loads without SSL errors
- [ ] Admin login works
- [ ] Device group created
- [ ] APK download link works
- [ ] Tablet appears in dashboard after agent install

## 🚨 If Still Having Issues

Run the troubleshooting script:
```bash
./troubleshoot.sh
```

Or check these immediately:

```bash
# Check what's using ports
sudo ss -tulpn | grep :80
sudo ss -tulpn | grep :443

# Check container status
docker ps | grep meshcentral

# Check logs
docker logs jd-meshcentral
```

## 🎉 Success Path

Once working:
1. ✅ You bypass Android 15 completely
2. ✅ Permanent access to all tablets
3. ✅ Professional service to offer customers
4. ✅ $15/device/month recurring revenue potential

---

**Go deploy Method 1 RIGHT NOW - this should solve your port conflicts and SSL issues!** 