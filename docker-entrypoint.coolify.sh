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
    echo "Starting Tomcat 9 via supervisord..."
    
    # Ensure Tomcat directories exist and have correct permissions
    mkdir -p /var/lib/tomcat9/conf/Catalina/localhost
    mkdir -p /var/log/tomcat9
    chown -R tomcat:tomcat /var/lib/tomcat9
    chown -R tomcat:tomcat /var/log/tomcat9
    
    echo "Configuring for Coolify deployment..."
    
    # Coolify handles SSL and reverse proxy, so we don't need nginx
    echo "Coolify will handle SSL certificates and reverse proxy"
    
    echo "Starting services via supervisor..."
    
    # Start supervisord in the background
    /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &
    
    # Wait a moment for supervisor to start
    sleep 5
    
    # Check if Tomcat is running
    echo "Checking Tomcat status..."
    supervisorctl status tomcat9 || echo "Tomcat status check failed, but continuing..."
    
    # Wait for Tomcat to be ready
    echo "Waiting for Tomcat to start on port 8080..."
    for i in {1..60}; do
        if curl -f http://localhost:8080/ >/dev/null 2>&1; then
            echo "Tomcat is ready!"
            break
        fi
        if [ $i -eq 60 ]; then
            echo "Tomcat failed to start in 60 seconds"
            # Show some debug info
            echo "=== Tomcat Logs ==="
            tail -50 /var/log/tomcat9/catalina.out 2>/dev/null || echo "No catalina.out found"
            echo "=== Process List ==="
            ps aux | grep -E "(tomcat|java)" || echo "No Java/Tomcat processes found"
        fi
        echo "Waiting for Tomcat... ($i/60)"
        sleep 1
    done
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

# Keep the container running by waiting for supervisord
wait 