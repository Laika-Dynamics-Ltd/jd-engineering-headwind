#!/bin/bash
set -e

echo "=== Headwind MDM Docker Quick Start ==="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << EOF
# Database Configuration
POSTGRES_PASSWORD=topsecret

# Application Configuration
DOMAIN=localhost
EMAIL=admin@example.com

# Java/Tomcat Configuration
JAVA_OPTS=-Xms512m -Xmx2048m
EOF
    echo "Created .env file with default values. Please edit if needed."
fi

# Create required directories
mkdir -p hmdm-config
mkdir -p scripts

# Make scripts executable
chmod +x docker-entrypoint.sh
chmod +x scripts/*.sh 2>/dev/null || true

echo "Starting Headwind MDM services..."

# Build and start services
docker-compose up -d --build

echo ""
echo "=== Services Starting ==="
echo "This may take several minutes on first run..."
echo ""
echo "Progress can be monitored with:"
echo "  docker-compose logs -f hmdm"
echo ""
echo "Once started, access the application at:"
echo "  HTTP:  http://localhost:8080"
echo "  HTTPS: https://localhost (if SSL configured)"
echo ""
echo "Default credentials: admin/admin"
echo "IMPORTANT: Change the default password immediately!"
echo ""
echo "To check status: docker-compose ps"
echo "To stop: docker-compose down"
echo ""

# Show real-time logs for 30 seconds
echo "Showing logs for 30 seconds..."
timeout 30 docker-compose logs -f hmdm || true

echo ""
echo "Setup complete! Check 'docker-compose ps' to verify all services are running." 