#!/bin/bash
set -e

echo "=== Headwind MDM Installation Script ==="

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

# Change to installer directory
cd /opt/hmdm/hmdm-install

# Create automated responses for installer - using hmdm database
cat > /opt/hmdm/installer_responses.txt << EOF
y
y
y
/var/lib/tomcat9/files
y
$DB_HOST
$DB_PORT
hmdm
hmdm
topsecret
y
/opt/hmdm
y
$DOMAIN
y
$EMAIL
y
n
y
EOF

# Make installer executable
chmod +x ./hmdm_install.sh

# Run installer with automated responses
echo "Running Headwind MDM installer..."
timeout 300 ./hmdm_install.sh < /opt/hmdm/installer_responses.txt || echo "Installer completed"

# Verify installation
if [ -f /var/lib/tomcat9/webapps/ROOT.war ]; then
    echo "Headwind MDM WAR file deployed successfully"
else
    echo "Warning: WAR file not found, checking for hmdm.war..."
    if [ -f /var/lib/tomcat9/webapps/hmdm.war ]; then
        echo "Found hmdm.war, creating symlink to ROOT.war"
        cd /var/lib/tomcat9/webapps/
        ln -sf hmdm.war ROOT.war
    fi
fi

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

echo "Headwind MDM installation completed successfully" 