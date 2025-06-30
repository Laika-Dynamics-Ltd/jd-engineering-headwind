#!/bin/bash
set -e

echo "=== Headwind MDM Production Deployment ==="

# Default values
SERVER_USER=""
SERVER_HOST=""
DOMAIN=""
EMAIL=""
POSTGRES_PASSWORD=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            SERVER_USER="$2"
            shift 2
            ;;
        --host)
            SERVER_HOST="$2"
            shift 2
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --email)
            EMAIL="$2"
            shift 2
            ;;
        --password)
            POSTGRES_PASSWORD="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 --user USER --host HOST --domain DOMAIN --email EMAIL [--password PASSWORD]"
            echo ""
            echo "Options:"
            echo "  --user       SSH username for the server"
            echo "  --host       Server hostname or IP address"
            echo "  --domain     Domain name for Headwind MDM"
            echo "  --email      Email for SSL certificate registration"
            echo "  --password   Database password (will prompt if not provided)"
            echo "  --help       Show this help message"
            echo ""
            echo "Example:"
            echo "  $0 --user root --host 192.168.1.100 --domain mdm.company.com --email admin@company.com"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$SERVER_USER" || -z "$SERVER_HOST" || -z "$DOMAIN" || -z "$EMAIL" ]]; then
    echo "Error: Missing required parameters"
    echo "Use --help for usage information"
    exit 1
fi

# Prompt for password if not provided
if [[ -z "$POSTGRES_PASSWORD" ]]; then
    echo -n "Enter PostgreSQL password: "
    read -s POSTGRES_PASSWORD
    echo
fi

echo "Deployment Configuration:"
echo "  Server: $SERVER_USER@$SERVER_HOST"
echo "  Domain: $DOMAIN"
echo "  Email: $EMAIL"
echo ""

# Confirm deployment
read -p "Continue with deployment? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Create deployment directory name
DEPLOY_DIR="headwind-mdm-$(date +%Y%m%d-%H%M%S)"

echo "=== Step 1: Preparing deployment package ==="
mkdir -p "deploy/$DEPLOY_DIR"

# Copy all necessary files
cp docker-compose.yml "deploy/$DEPLOY_DIR/"
cp Dockerfile "deploy/$DEPLOY_DIR/"
cp docker-entrypoint.sh "deploy/$DEPLOY_DIR/"
cp supervisord.conf "deploy/$DEPLOY_DIR/"
cp nginx.conf "deploy/$DEPLOY_DIR/"
cp init-db.sql "deploy/$DEPLOY_DIR/"
cp -r scripts "deploy/$DEPLOY_DIR/"
cp -r hmdm-config "deploy/$DEPLOY_DIR/"
cp README.md "deploy/$DEPLOY_DIR/"

# Create production .env file
cat > "deploy/$DEPLOY_DIR/.env" << EOF
# Database Configuration
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Application Configuration  
DOMAIN=$DOMAIN
EMAIL=$EMAIL

# Java/Tomcat Configuration
JAVA_OPTS=-Xms1g -Xmx4g

# Production flags
ENABLE_SSL=true
EOF

# Create server setup script
cat > "deploy/$DEPLOY_DIR/server-setup.sh" << 'EOF'
#!/bin/bash
set -e

echo "=== Server Setup for Headwind MDM ==="

# Update system
apt-get update
apt-get upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Configure firewall
echo "Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp  
ufw allow 443/tcp
ufw --force enable

# Create application directory
mkdir -p /opt/headwind-mdm
cd /opt/headwind-mdm

echo "Server setup completed!"
EOF

chmod +x "deploy/$DEPLOY_DIR/server-setup.sh"

echo "=== Step 2: Uploading to server ==="
# Create archive
cd deploy
tar -czf "$DEPLOY_DIR.tar.gz" "$DEPLOY_DIR"

# Upload to server
scp "$DEPLOY_DIR.tar.gz" "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "=== Step 3: Installing on server ==="
ssh "$SERVER_USER@$SERVER_HOST" << EOF
set -e

# Extract deployment package
cd /tmp
tar -xzf "$DEPLOY_DIR.tar.gz"

# Setup server (if needed)
chmod +x "$DEPLOY_DIR/server-setup.sh"
./"$DEPLOY_DIR/server-setup.sh"

# Move to production directory
if [ -d /opt/headwind-mdm ]; then
    # Backup existing installation
    if [ -d /opt/headwind-mdm-backup ]; then
        rm -rf /opt/headwind-mdm-backup
    fi
    mv /opt/headwind-mdm /opt/headwind-mdm-backup
fi

mv "$DEPLOY_DIR" /opt/headwind-mdm
cd /opt/headwind-mdm

# Make scripts executable
chmod +x docker-entrypoint.sh
chmod +x scripts/*.sh

# Start services
echo "Starting Headwind MDM services..."
docker-compose down || true
docker-compose up -d --build

echo ""
echo "=== Deployment Complete! ==="
echo ""
echo "Your Headwind MDM installation is starting..."
echo "Access it at: https://$DOMAIN"
echo ""
echo "Monitor progress with:"
echo "  docker-compose logs -f hmdm"
echo ""
echo "Check status with:"
echo "  docker-compose ps"
echo ""
echo "Default credentials: admin/admin"
echo "IMPORTANT: Change the password immediately!"

# Cleanup
rm -f "/tmp/$DEPLOY_DIR.tar.gz"
EOF

echo ""
echo "=== Deployment Summary ==="
echo "✅ Package created and uploaded"
echo "✅ Server configured"  
echo "✅ Services started"
echo ""
echo "🌐 URL: https://$DOMAIN"
echo "🔐 Default login: admin/admin"
echo ""
echo "Next steps:"
echo "1. Wait 2-3 minutes for full startup"
echo "2. Access https://$DOMAIN"
echo "3. Change default password"
echo "4. Configure your MDM settings"
echo ""
echo "Monitor with: ssh $SERVER_USER@$SERVER_HOST 'cd /opt/headwind-mdm && docker-compose logs -f'"

# Cleanup local deployment files
cd ..
rm -rf "deploy/$DEPLOY_DIR"
rm -f "deploy/$DEPLOY_DIR.tar.gz"

echo ""
echo "🚀 Deployment completed successfully!" 