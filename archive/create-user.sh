#!/bin/bash

# Commands to run on your VPS server to create a deployment user

echo "🔐 Creating secure deployment user for MeshCentral setup"
echo "======================================================="

echo ""
echo "Run these commands on your VPS server (as root):"
echo ""

cat << 'EOF'

# 1. Create a new user for deployment
useradd -m -s /bin/bash deploy

# 2. Add user to sudo group
usermod -aG sudo deploy

# 3. Set a temporary password (you can change this)
echo 'deploy:TempPass123!' | chpasswd

# 4. Allow passwordless sudo for docker commands (optional, safer)
echo 'deploy ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose, /usr/sbin/ufw' >> /etc/sudoers.d/deploy

# 5. Test the user creation
su - deploy -c "whoami && groups"

# 6. Show the connection details
echo "✅ User created successfully!"
echo "SSH connection: ssh deploy@194.238.17.65"
echo "Password: TempPass123!"
echo ""
echo "You can now give these credentials to proceed with MeshCentral deployment."

EOF

echo ""
echo "🔑 ALTERNATIVE: SSH Key Method (More Secure)"
echo "============================================"

cat << 'EOF'

# Generate SSH key pair on your local machine
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N ""

# Copy the public key to the server
ssh-copy-id -i ~/.ssh/deploy_key.pub deploy@194.238.17.65

# Then connection would be:
ssh -i ~/.ssh/deploy_key deploy@194.238.17.65

EOF

echo ""
echo "🎯 Once user is created, I can:"
echo "==============================="
echo "• Connect safely with limited privileges"
echo "• Deploy MeshCentral without disrupting Coolify"
echo "• Check existing services first"
echo "• Use non-conflicting ports"
echo "• Provide full deployment documentation" 