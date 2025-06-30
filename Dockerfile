FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install required software
RUN apt-get update && apt-get install -y \
    aapt \
    tomcat9 \
    postgresql-client \
    vim \
    certbot \
    unzip \
    net-tools \
    wget \
    curl \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Add Ubuntu 22.04 (jammy) repository for Tomcat 9 if needed
RUN add-apt-repository -y -s "deb http://archive.ubuntu.com/ubuntu/ jammy main universe" || true

# Create hmdm directory
RUN mkdir -p /opt/hmdm

# Set up Tomcat directories and permissions
RUN mkdir -p /var/lib/tomcat9/conf/Catalina/localhost \
    && mkdir -p /var/log/tomcat9 \
    && chown -R tomcat:tomcat /var/lib/tomcat9 \
    && chown -R tomcat:tomcat /var/log/tomcat9

# Download and extract Headwind MDM installer
WORKDIR /tmp
RUN wget https://h-mdm.com/files/hmdm-5.35-install-ubuntu.zip \
    && unzip hmdm-5.35-install-ubuntu.zip \
    && mv hmdm-install /opt/hmdm/

# Copy custom installation script and configuration files
COPY scripts/ /opt/hmdm/scripts/
COPY config/ /opt/hmdm/config/

# Make scripts executable
RUN chmod +x /opt/hmdm/scripts/*.sh

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy nginx configuration
COPY nginx.conf /etc/nginx/sites-available/default

# Create startup script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose ports
EXPOSE 80 443 8080

# Set working directory
WORKDIR /opt/hmdm

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start services
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 