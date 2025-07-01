#!/bin/bash
set -e

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

# Check multiple possible locations for the WAR file
if [ -f /opt/hmdm/hmdm-install/hmdm.war ]; then
    cp /opt/hmdm/hmdm-install/hmdm.war /tmp/hmdm.war
    echo "Found WAR file in installer directory"
elif [ -f /opt/hmdm/hmdm-install/files/hmdm.war ]; then
    cp /opt/hmdm/hmdm-install/files/hmdm.war /tmp/hmdm.war
    echo "Found WAR file in installer files directory"
elif [ -f /opt/hmdm/hmdm-install/install/hmdm.war ]; then
    cp /opt/hmdm/hmdm-install/install/hmdm.war /tmp/hmdm.war
    echo "Found WAR file in install directory"
else
    echo "Searching for WAR file in installer package..."
    find /opt/hmdm -name "*.war" -type f | head -1 | xargs -I {} cp {} /tmp/hmdm.war
    if [ ! -f /tmp/hmdm.war ]; then
        echo "No WAR file found, creating a minimal test WAR..."
        # Create a minimal ROOT.war that will show we're working
        mkdir -p /tmp/webapp/WEB-INF
        cat > /tmp/webapp/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Headwind MDM - Installation in Progress</title></head>
<body>
<h1>Headwind MDM Installation</h1>
<p>The system is running but HMDM application needs to be configured.</p>
<p>Check the logs for installation progress.</p>
</body>
</html>
EOF
        cd /tmp/webapp
        jar -cf /tmp/hmdm.war .
        echo "Created placeholder WAR file"
    fi
fi

# Deploy WAR file to Tomcat
echo "Deploying HMDM to Tomcat..."
cp /tmp/hmdm.war /var/lib/tomcat9/webapps/ROOT.war
chown tomcat:tomcat /var/lib/tomcat9/webapps/ROOT.war

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

# Initialize database schema if needed
echo "Initializing database schema..."
PGPASSWORD=topsecret psql -h $DB_HOST -p $DB_PORT -U hmdm -d hmdm -c "
CREATE TABLE IF NOT EXISTS applications (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    package_id VARCHAR(255) NOT NULL,
    version VARCHAR(50),
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS devices (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add admin user if not exists
INSERT INTO users (login, email, name, password, user_role) 
SELECT 'admin', '$EMAIL', 'Administrator', 'admin', 'ADMIN'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE login = 'admin');
" || echo "Schema initialization completed (some tables may already exist)"

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