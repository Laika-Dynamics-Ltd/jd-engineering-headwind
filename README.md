# Headwind MDM Docker Setup

Production-ready Docker Compose setup for Headwind MDM with PostgreSQL database.

## Features

- **Ubuntu 22.04** base image with all required dependencies
- **PostgreSQL 15** database with automatic initialization
- **Tomcat 9** application server with proper configuration
- **Nginx** reverse proxy with SSL support
- **Supervisor** for process management
- **Automated installation** of Headwind MDM
- **Persistent volumes** for data retention
- **Health checks** and auto-restart capabilities

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM and 20GB disk space
- Domain name (for production with SSL)

### 1. Clone and Setup

```bash
git clone <your-repo>
cd headwind-mdm-docker
```

### 2. Configure Environment

Create a `.env` file:

```bash
# Database Configuration
POSTGRES_PASSWORD=your-secure-password

# Application Configuration
DOMAIN=your-domain.com
EMAIL=your-email@domain.com

# Java/Tomcat Configuration
JAVA_OPTS=-Xms512m -Xmx2048m
```

### 3. Start Services

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f hmdm

# Check status
docker-compose ps
```

### 4. Access Application

- **HTTP**: http://localhost:8080 or http://your-domain.com
- **HTTPS**: https://your-domain.com (after SSL setup)
- **Default credentials**: admin/admin (change immediately)

## Directory Structure

```
.
├── docker-compose.yml      # Main compose file
├── Dockerfile             # Application container build
├── docker-entrypoint.sh   # Container startup script
├── supervisord.conf       # Process management
├── nginx.conf             # Nginx configuration
├── init-db.sql           # Database initialization
├── scripts/
│   └── install-hmdm.sh   # Automated installer
└── README.md             # This file
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_PASSWORD` | `topsecret` | Database password |
| `DOMAIN` | `localhost` | Domain name for the application |
| `EMAIL` | `admin@example.com` | Admin email for SSL certificates |
| `JAVA_OPTS` | `-Xms512m -Xmx2048m` | JVM memory settings |

### Ports

| Port | Service | Description |
|------|---------|-------------|
| 80 | Nginx | HTTP access |
| 443 | Nginx | HTTPS access |
| 8080 | Tomcat | Direct Tomcat access |
| 5432 | PostgreSQL | Database (internal only) |

### Volumes

| Volume | Purpose |
|--------|---------|
| `postgres_data` | Database storage |
| `hmdm_data` | Application data |
| `tomcat_data` | Tomcat configuration |
| `tomcat_logs` | Application logs |
| `letsencrypt_data` | SSL certificates |

## Production Deployment

### SSL Configuration

For production with a real domain:

1. **Update environment**:
   ```bash
   DOMAIN=your-domain.com
   EMAIL=your-email@domain.com
   ```

2. **Ensure DNS points to your server**

3. **Restart services**:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

4. **SSL certificates will be automatically obtained** via Let's Encrypt

### Performance Tuning

For high-load environments:

```bash
# Increase JVM memory
JAVA_OPTS=-Xms1g -Xmx4g

# Scale PostgreSQL
# Edit docker-compose.yml to add PostgreSQL performance settings
```

## Maintenance

### Backup

```bash
# Backup database
docker-compose exec postgres pg_dump -U hmdm hmdm > backup.sql

# Backup volumes
docker run --rm -v hmdm_data:/data -v $(pwd):/backup ubuntu tar czf /backup/hmdm-data.tar.gz /data
```

### Restore

```bash
# Restore database
docker-compose exec -T postgres psql -U hmdm hmdm < backup.sql

# Restore volumes
docker run --rm -v hmdm_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/hmdm-data.tar.gz -C /
```

### Updates

```bash
# Pull latest images
docker-compose pull

# Rebuild application
docker-compose build --no-cache hmdm

# Restart services
docker-compose down
docker-compose up -d
```

### Monitoring

```bash
# View logs
docker-compose logs -f

# Check resource usage
docker stats

# Health check
curl http://localhost/health
```

## Troubleshooting

### Common Issues

1. **Installation fails**:
   - Check logs: `docker-compose logs hmdm`
   - Verify database connectivity
   - Ensure sufficient disk space

2. **Cannot access web interface**:
   - Check if Tomcat is running: `docker-compose exec hmdm supervisorctl status`
   - Verify ports are not blocked by firewall
   - Check nginx configuration

3. **Database connection errors**:
   - Verify PostgreSQL is running: `docker-compose ps`
   - Check database credentials in logs
   - Ensure volumes are properly mounted

4. **SSL certificate issues**:
   - Verify domain DNS points to server
   - Check Let's Encrypt rate limits
   - Ensure port 80/443 are accessible

### Debug Commands

```bash
# Enter application container
docker-compose exec hmdm bash

# Check Tomcat status
docker-compose exec hmdm supervisorctl status tomcat9

# View Tomcat logs
docker-compose exec hmdm tail -f /var/log/supervisor/tomcat9.out.log

# Check database
docker-compose exec postgres psql -U hmdm hmdm

# Test connectivity
docker-compose exec hmdm curl http://localhost:8080
```

## Support

- **Headwind MDM Documentation**: https://h-mdm.com/
- **Installation Guide**: https://h-mdm.com/advanced-web-panel-installation/
- **GitHub Issues**: Create an issue for Docker-specific problems

## License

This Docker setup is provided as-is. Headwind MDM itself is subject to its own licensing terms.

## Security Notes

- Change default passwords immediately
- Use strong passwords for production
- Keep the system updated
- Configure firewall rules appropriately
- Use SSL certificates for production
- Regular security audits recommended 