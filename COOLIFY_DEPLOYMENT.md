# 🚀 Deploy Headwind MDM on Coolify

Deploy Headwind MDM easily using Coolify with automatic SSL certificates, reverse proxy, and domain management.

## ✨ What You Get

- 🔄 **Automatic SSL certificates** via Let's Encrypt
- 🌐 **Custom domain support** with Coolify's Traefik proxy
- 📊 **Built-in monitoring** and logging
- 🔄 **Auto-restart** and health checks
- 📦 **One-click deployment** from Git repository
- 🛡️ **Production-ready** configuration

## 📋 Prerequisites

1. **Coolify Instance**: Running Coolify server
2. **Domain**: Domain name pointing to your Coolify server
3. **Git Repository**: This Headwind MDM code pushed to Git
4. **Server Resources**: 4GB+ RAM, 2+ CPU cores

## 🚀 Deployment Steps

### 1. Create New Project in Coolify

1. Login to your Coolify dashboard
2. Click **"+ New"** → **"Project"**
3. Name: `headwind-mdm`
4. Description: `Headwind MDM - Mobile Device Management`

### 2. Add Resource (Docker Compose)

1. In your project, click **"+ New Resource"**
2. Select **"Docker Compose"**
3. Choose **"Public Repository"** or connect your private Git

### 3. Configure Repository

**Public Repository Settings:**
- **Repository URL**: `https://github.com/your-username/headwind-mdm`
- **Branch**: `main` 
- **Docker Compose File**: `docker-compose.coolify.yml`

### 4. Set Environment Variables

In Coolify's Environment tab, add:

```bash
# Database
POSTGRES_PASSWORD=your-super-secure-password

# Application  
DOMAIN=mdm.yourdomain.com
EMAIL=admin@yourdomain.com

# Performance
JAVA_OPTS=-Xms1g -Xmx4g
```

### 5. Configure Domain

1. Go to **"Domains"** tab
2. Add your domain: `mdm.yourdomain.com`
3. Coolify automatically configures:
   - SSL certificate (Let's Encrypt)
   - Reverse proxy routing
   - HTTP → HTTPS redirect

### 6. Deploy

1. Click **"Deploy"** 
2. Watch real-time logs in the **"Logs"** tab
3. Wait 3-5 minutes for initial setup

### 7. Access Application

- **URL**: `https://mdm.yourdomain.com`
- **Default Login**: `admin` / `admin`
- **⚠️ Change password immediately!**

## 📁 File Structure for Coolify

```
your-repo/
├── docker-compose.coolify.yml    # Main Coolify compose file
├── Dockerfile.coolify            # Coolify-optimized container
├── docker-entrypoint.coolify.sh  # Coolify startup script
├── supervisord.coolify.conf      # Process management
├── coolify.env.example          # Environment template
├── scripts/
│   └── install-hmdm.sh          # Automated installer
└── README.md                    # General documentation
```

## ⚙️ Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `POSTGRES_PASSWORD` | ✅ | - | Database password |
| `DOMAIN` | ✅ | - | Your domain (e.g., mdm.company.com) |
| `EMAIL` | ✅ | - | Admin email for SSL certificates |
| `JAVA_OPTS` | ❌ | `-Xms1g -Xmx4g` | JVM memory settings |

## 📊 Monitoring & Management

### View Logs
- **Real-time**: Coolify → Logs tab
- **Container logs**: Click on individual services

### Check Health
- **Status**: Coolify → Resources tab shows service health
- **Metrics**: Built-in resource usage graphs

### Restart Services
- **Full restart**: Coolify → Deploy button
- **Single service**: Restart individual containers

## 🔧 Customization

### Increase Memory for High Load

In Environment variables:
```bash
JAVA_OPTS=-Xms2g -Xmx8g
```

### Custom Domain Setup

1. **DNS**: Point your domain to Coolify server IP
2. **Coolify**: Add domain in Domains tab
3. **SSL**: Automatically handled by Coolify

## 🐛 Troubleshooting

### Common Issues

**1. Deployment Fails**
```bash
# Check logs in Coolify
# Verify environment variables are set
# Ensure domain DNS is pointing correctly
```

**2. Can't Access Application**
```bash
# Verify domain is added in Coolify
# Check if SSL certificate was issued
# Confirm firewall allows ports 80/443
```

**3. Database Connection Errors**
```bash
# Check POSTGRES_PASSWORD is set
# Verify containers can communicate
# Look at postgres service logs
```

**4. Application Won't Start**
```bash
# Check available memory (need 4GB+)
# Verify JAVA_OPTS settings
# Check Tomcat logs in Coolify
```

### Debug Commands

Access container via Coolify terminal:

```bash
# Check service status
supervisorctl status

# View Tomcat logs
tail -f /var/log/supervisor/tomcat9.out.log

# Test database connection
pg_isready -h postgres -p 5432 -U hmdm

# Check application health
curl http://localhost:8080
```

## 🔄 Updates & Maintenance

### Update Headwind MDM

1. **Push changes** to your Git repository
2. **Click Deploy** in Coolify
3. **Monitor deployment** in logs
4. **Verify application** is working

### Backup

Coolify provides built-in backup options:
- **Database**: Automatic PostgreSQL backups
- **Volumes**: Persistent data storage
- **Configuration**: Environment variables saved

### Scaling

For high-load environments:
- **Increase resources** in Coolify server settings
- **Adjust JAVA_OPTS** for more memory
- **Monitor performance** via Coolify metrics

## 🛡️ Security

### Post-Deployment Security

1. **Change default password** (`admin`/`admin`)
2. **Review user permissions** in Headwind MDM
3. **Configure device policies**
4. **Set up regular backups**
5. **Monitor access logs**

### SSL Certificates

- **Automatic renewal** by Coolify
- **A+ SSL rating** with modern TLS
- **HSTS headers** for security

## 📚 Resources

- **Coolify Docs**: https://coolify.io/docs
- **Headwind MDM**: https://h-mdm.com/
- **Troubleshooting**: Check Coolify logs first
- **Support**: GitHub issues for this deployment

## 🎯 Next Steps

After successful deployment:

1. 🔐 **Change admin password**
2. 📱 **Configure device policies**
3. 📊 **Set up monitoring alerts**
4. 👥 **Add additional users**
5. 🔄 **Schedule regular backups**

---

**Your Headwind MDM is now running on Coolify with automatic SSL, monitoring, and easy management!** 🎉

For issues specific to Coolify deployment, check the logs in your Coolify dashboard first. 