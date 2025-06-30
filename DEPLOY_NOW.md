# 🚀 Deploy Headwind MDM Right Now

## Quick Deployment Command

```bash
./deploy.sh --user root --host YOUR_SERVER_IP --domain YOUR_DOMAIN.com --email YOUR_EMAIL@domain.com
```

## Prerequisites

1. **Server Requirements:**
   - Ubuntu 22.04 LTS server
   - Minimum 4GB RAM, 2 CPU cores, 20GB storage
   - SSH access as root (or sudo user)
   - Public IP address
   - Ports 22, 80, 443 open

2. **Domain Setup:**
   - Domain name pointing to your server's public IP
   - DNS A record: `your-domain.com` → `YOUR_SERVER_IP`

3. **Local Requirements:**
   - SSH access to the server
   - This deployment package

## Step-by-Step Deployment

### 1. Replace Values and Run

```bash
# Example deployment command
./deploy.sh \
  --user root \
  --host 192.168.1.100 \
  --domain mdm.yourcompany.com \
  --email admin@yourcompany.com
```

### 2. The Script Will:
- ✅ Package all Docker files
- ✅ Upload to your server  
- ✅ Install Docker & Docker Compose
- ✅ Configure firewall
- ✅ Start Headwind MDM services
- ✅ Set up SSL certificates automatically

### 3. Access Your Installation
- **URL:** `https://your-domain.com`
- **Login:** `admin` / `admin`
- **⚠️ IMPORTANT:** Change password immediately!

## Example Real Deployment

```bash
# For a production server at 203.0.113.50 with domain mdm.acme.com
./deploy.sh \
  --user root \
  --host 203.0.113.50 \
  --domain mdm.acme.com \
  --email it-admin@acme.com
```

## Monitor Deployment

After deployment, monitor the startup:

```bash
# SSH to your server and check status
ssh root@YOUR_SERVER_IP

# Check services
cd /opt/headwind-mdm
docker-compose ps

# Watch logs
docker-compose logs -f hmdm
```

## Troubleshooting

### If deployment fails:
1. Check SSH connectivity: `ssh root@YOUR_SERVER_IP`
2. Verify domain DNS: `nslookup YOUR_DOMAIN.com`
3. Check server resources: `free -h` and `df -h`

### Common issues:
- **DNS not pointing to server:** Update your domain's A record
- **Ports blocked:** Check firewall/security groups
- **Insufficient resources:** Upgrade server specs

## Security Notes

🔒 **Immediately after deployment:**
1. Change admin password
2. Review firewall settings
3. Set up regular backups
4. Update server packages

## Need Help?

Run with `--help` for all options:
```bash
./deploy.sh --help
```

---

**Ready to deploy? Run the command above with your server details!** 🚀 