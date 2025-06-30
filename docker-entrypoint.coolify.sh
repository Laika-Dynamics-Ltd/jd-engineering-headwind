#!/bin/bash
set -e

# Function to wait for database
wait_for_database() {
    echo "Waiting for PostgreSQL to be ready..."
    until pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 2
    done
    echo "PostgreSQL is up - continuing"
}

# Function to check if HMDM is already installed
is_hmdm_installed() {
    [ -f /opt/hmdm/.installed ]
}

# Function to install HMDM
install_hmdm() {
    echo "Installing Headwind MDM for Coolify..."
    
    # Wait for database
    wait_for_database
    
    # Run custom installation script
    /opt/hmdm/scripts/install-hmdm.sh
    
    # Mark as installed
    touch /opt/hmdm/.installed
    
    echo "Headwind MDM installation completed"
}

# Function to start services
start_services() {
    echo "Starting Tomcat 9..."
    systemctl enable tomcat9 || true
    
    echo "Configuring for Coolify deployment..."
    
    # Coolify handles SSL and reverse proxy, so we don't need nginx
    echo "Coolify will handle SSL certificates and reverse proxy"
    
    echo "Starting services via supervisor..."
}

# Main execution
echo "=== Headwind MDM Docker Container Starting (Coolify) ==="
echo "Domain: $DOMAIN"
echo "Database: $DB_HOST:$DB_PORT/$DB_NAME"

# Check if this is first run
if ! is_hmdm_installed; then
    install_hmdm
else
    echo "Headwind MDM already installed, starting services..."
    wait_for_database
fi

# Backup Tomcat configuration
if [ -f /var/lib/tomcat9/conf/Catalina/localhost/ROOT.xml ]; then
    cp /var/lib/tomcat9/conf/Catalina/localhost/ROOT.xml /var/lib/tomcat9/conf/Catalina/localhost/ROOT.xml~
fi

start_services

echo "=== Headwind MDM Ready for Coolify ==="
echo "Access via Coolify's domain: https://$DOMAIN"
echo "Tomcat running on port 8080 (internal)"

# Execute the command passed to the container
exec "$@" 