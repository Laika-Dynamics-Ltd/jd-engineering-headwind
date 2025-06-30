#!/bin/bash
set -e

echo "🚀 Preparing Headwind MDM for Coolify Deployment"

# Check if we're in the right directory
if [ ! -f "docker-compose.coolify.yml" ]; then
    echo "❌ Error: docker-compose.coolify.yml not found"
    echo "Please run this script from the Headwind MDM project directory"
    exit 1
fi

# Make scripts executable
echo "📝 Making scripts executable..."
chmod +x docker-entrypoint.coolify.sh
chmod +x scripts/*.sh 2>/dev/null || true

# Verify required files exist
echo "✅ Verifying Coolify deployment files..."

required_files=(
    "docker-compose.coolify.yml"
    "Dockerfile.coolify"
    "docker-entrypoint.coolify.sh"
    "supervisord.coolify.conf"
    "coolify.env.example"
    "scripts/install-hmdm.sh"
    "COOLIFY_DEPLOYMENT.md"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -ne 0 ]; then
    echo "❌ Missing required files:"
    printf '%s\n' "${missing_files[@]}"
    exit 1
fi

echo "✅ All required files present!"

# Create .gitignore if it doesn't exist or update it
echo "📝 Updating .gitignore..."
cat > .gitignore << EOF
# Environment files
.env
.env.local
.env.production

# Logs
logs/
*.log
npm-debug.log*

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Dependency directories
node_modules/

# Docker
.dockerignore

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Build artifacts
dist/
build/
target/

# Temporary files
tmp/
temp/
EOF

# Verify Git repository
if [ ! -d ".git" ]; then
    echo "⚠️  Warning: Not a Git repository. Initializing..."
    git init
    git add .
    git commit -m "Initial commit: Headwind MDM for Coolify"
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository detected"
fi

# Show deployment instructions
echo ""
echo "🎉 Coolify Deployment Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 📤 Push to Git repository:"
echo "   git add ."
echo "   git commit -m 'Add Coolify deployment configuration'"
echo "   git push origin main"
echo ""
echo "2. 🌐 Setup in Coolify:"
echo "   - Create new project: 'headwind-mdm'"
echo "   - Add Docker Compose resource"
echo "   - Repository: <your-git-repo-url>"
echo "   - Docker Compose file: docker-compose.coolify.yml"
echo ""
echo "3. ⚙️ Set Environment Variables:"
echo "   POSTGRES_PASSWORD=your-secure-password"
echo "   DOMAIN=mdm.yourdomain.com"
echo "   EMAIL=admin@yourdomain.com"
echo "   JAVA_OPTS=-Xms1g -Xmx4g"
echo ""
echo "4. 🚀 Deploy!"
echo ""
echo "📖 Full instructions: See COOLIFY_DEPLOYMENT.md"
echo ""
echo "✨ Your Headwind MDM will be accessible at https://your-domain.com"
echo "🔐 Default login: admin/admin (change immediately!)" 