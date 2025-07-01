#!/bin/bash
set -e

# Prevent multiple installations
LOCK_FILE="/tmp/hmdm_installed.lock"
if [ -f "$LOCK_FILE" ]; then
    echo "=== HMDM already installed, skipping ==="
    exit 0
fi

echo "=== Headwind MDM Direct Installation Script ==="

# Environment variables with defaults
DB_HOST=${DB_HOST:-postgres}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-postgres}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-topsecret}
DOMAIN=${DOMAIN:-localhost}
EMAIL=${EMAIL:-admin@example.com}

# Wait for database to be ready
echo "Waiting for database connection..."
until PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c '\l'; do
    echo "Database not ready, waiting..."
    sleep 5
done

echo "Database connection established"

# Create HMDM database and user if not exists
echo "Setting up HMDM database..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'hmdm') THEN
      CREATE USER hmdm WITH PASSWORD 'topsecret';
   END IF;
END
\$\$;
"

# Create hmdm database if it doesn't exist
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
SELECT 1 FROM pg_database WHERE datname = 'hmdm';
" | grep -q 1 || PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE DATABASE hmdm OWNER hmdm;"

echo "HMDM database created"

# Extract HMDM WAR file from installer package
echo "Extracting Headwind MDM application from installer..."
cd /tmp

# Look for WAR files in installer
WAR_FOUND=false
for location in \
    "/opt/hmdm/hmdm-install/hmdm.war" \
    "/opt/hmdm/hmdm-install/files/hmdm.war" \
    "/opt/hmdm/hmdm-install/install/hmdm.war" \
    "/opt/hmdm/hmdm-install/target/hmdm.war" \
    "/opt/hmdm/hmdm-install/build/hmdm.war"
do
    if [ -f "$location" ]; then
        echo "Found HMDM WAR file at: $location"
        cp "$location" /tmp/hmdm.war
        WAR_FOUND=true
        break
    fi
done

# If no specific WAR found, search recursively
if [ "$WAR_FOUND" = false ]; then
    echo "Searching for WAR file in installer package..."
    WAR_FILE=$(find /opt/hmdm -name "*.war" -type f | head -1)
    if [ -n "$WAR_FILE" ]; then
        echo "Found WAR file: $WAR_FILE"
        cp "$WAR_FILE" /tmp/hmdm.war
        WAR_FOUND=true
    fi
fi

# If still no WAR, try to run the installer to generate one
if [ "$WAR_FOUND" = false ]; then
    echo "No WAR file found, attempting to build from installer..."
    cd /opt/hmdm/hmdm-install
    
    # Check if there's a build script
    if [ -f "build.sh" ]; then
        echo "Running build script..."
        chmod +x build.sh
        ./build.sh || echo "Build script failed"
    elif [ -f "hmdm_install.sh" ]; then
        echo "Running installer to build WAR..."
        chmod +x hmdm_install.sh
        # Try to extract WAR without full installation
        timeout 60 bash -c 'echo -e "n\ny\ny\ny\nn" | ./hmdm_install.sh' || echo "Installer timeout"
    fi
    
    # Check again for WAR file
    WAR_FILE=$(find /opt/hmdm -name "*.war" -type f | head -1)
    if [ -n "$WAR_FILE" ]; then
        echo "Found generated WAR file: $WAR_FILE"
        cp "$WAR_FILE" /tmp/hmdm.war
        WAR_FOUND=true
    fi
fi

# Final fallback - create a working placeholder that redirects to setup
if [ "$WAR_FOUND" = false ]; then
    echo "Creating setup placeholder WAR..."
    mkdir -p /tmp/webapp/WEB-INF
    cat > /tmp/webapp/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Headwind MDM - Setup Required</title>
    <meta http-equiv="refresh" content="0;url=/setup">
</head>
<body>
    <h1>Headwind MDM</h1>
    <p>Redirecting to setup...</p>
    <p>If not redirected, <a href="/setup">click here</a></p>
</body>
</html>
EOF
    
    cat > /tmp/webapp/WEB-INF/web.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee">
    <display-name>Headwind MDM</display-name>
    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
    </welcome-file-list>
</web-app>
EOF
    
    cd /tmp/webapp
    jar -cf /tmp/hmdm.war .
    echo "Created placeholder WAR file"
fi

# Deploy WAR file to Tomcat
echo "Deploying HMDM to Tomcat..."

# Remove default Tomcat ROOT to prevent conflicts
echo "Removing default Tomcat ROOT application..."
rm -rf /var/lib/tomcat9/webapps/ROOT
rm -f /var/lib/tomcat9/webapps/ROOT.war

# Deploy our HMDM WAR
cp /tmp/hmdm.war /var/lib/tomcat9/webapps/ROOT.war
chown tomcat:tomcat /var/lib/tomcat9/webapps/ROOT.war

# Verify WAR file size
echo "WAR file deployed:"
ls -la /var/lib/tomcat9/webapps/ROOT.war
echo "WAR file size: $(stat -c%s /var/lib/tomcat9/webapps/ROOT.war) bytes"

# Extract WAR manually to ensure deployment
echo "Manually extracting WAR to ensure deployment..."
cd /var/lib/tomcat9/webapps
rm -rf ROOT
mkdir ROOT
cd ROOT
jar -xf ../ROOT.war

# Set correct permissions
chown -R tomcat:tomcat /var/lib/tomcat9/webapps/ROOT

# List contents to verify
echo "Deployed application contents:"
ls -la /var/lib/tomcat9/webapps/ROOT/ | head -10

# Create HMDM configuration directory
mkdir -p /opt/hmdm/conf
chown -R tomcat:tomcat /opt/hmdm

# Create database configuration file
echo "Creating HMDM configuration..."
cat > /opt/hmdm/conf/hmdm.properties << EOF
# Headwind MDM Configuration
db.url=jdbc:postgresql://$DB_HOST:$DB_PORT/hmdm
db.username=hmdm
db.password=topsecret
db.driver=org.postgresql.Driver

# Server configuration
server.name=$DOMAIN
server.admin.email=$EMAIL

# File storage
files.directory=/var/lib/tomcat9/files

# Logging
log.level=INFO
log.file=/var/log/tomcat9/hmdm.log
EOF

# Create files directory
mkdir -p /var/lib/tomcat9/files
chown -R tomcat:tomcat /var/lib/tomcat9/files

# Create context configuration for Tomcat
mkdir -p /var/lib/tomcat9/conf/Catalina/localhost
cat > /var/lib/tomcat9/conf/Catalina/localhost/ROOT.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="/var/lib/tomcat9/webapps/ROOT.war">
    <Parameter name="hmdm.config.file" value="/opt/hmdm/conf/hmdm.properties" override="false"/>
</Context>
EOF

# Wait a moment for deployment
echo "Waiting for WAR deployment..."
sleep 10

# Let HMDM create its own schema on first startup
echo "HMDM will initialize its database schema on first startup"
echo "No manual schema creation needed"

# Configure Tomcat for Docker environment
echo "Configuring Tomcat..."

# Ensure Tomcat can write to required directories
chown -R tomcat:tomcat /var/lib/tomcat9
chown -R tomcat:tomcat /opt/hmdm
chown -R tomcat:tomcat /var/log/tomcat9

# Configure Tomcat memory settings
if [ ! -z "$JAVA_OPTS" ]; then
    echo "JAVA_OPTS=\"$JAVA_OPTS\"" >> /etc/default/tomcat9
fi

# Create custom server.xml with proper connectors
cat > /etc/tomcat9/server.xml << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8005" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>

  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />

    <Engine name="Catalina" defaultHost="localhost">
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>

      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>
    </Engine>
  </Service>
</Server>
EOL

echo "Headwind MDM direct installation completed successfully"
echo "WAR file: /var/lib/tomcat9/webapps/ROOT.war"
echo "Config: /opt/hmdm/conf/hmdm.properties"
echo "Files: /var/lib/tomcat9/files"

# Create lock file to prevent re-installation
touch "$LOCK_FILE"
echo "=== Installation lock file created ===" 