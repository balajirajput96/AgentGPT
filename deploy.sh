#!/bin/bash

# AgentGPT Deployment Script
# This script helps you deploy AgentGPT to production

set -e

echo "🚀 AgentGPT Production Deployment Script"
echo "=========================================="

# Check if docker and docker-compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose is not installed. Please install docker-compose first."
    exit 1
fi

# Check if .env.prod exists
if [ ! -f .env.prod ]; then
    echo "⚠️  .env.prod not found. Creating from template..."
    if [ -f .env.prod.example ]; then
        cp .env.prod.example .env.prod
        echo "✅ Created .env.prod from .env.prod.example"
        echo ""
        echo "⚠️  IMPORTANT: Please edit .env.prod with your production values before continuing!"
        echo "   You need to set:"
        echo "   - NEXTAUTH_SECRET (generate with: openssl rand -base64 32)"
        echo "   - NEXTAUTH_URL (your domain URL)"
        echo "   - REWORKD_PLATFORM_OPENAI_API_KEY (your OpenAI API key)"
        echo "   - Database passwords"
        echo "   - Other API keys as needed"
        echo ""
        read -p "Press Enter after you've edited .env.prod to continue..."
    else
        echo "❌ Error: .env.prod.example not found. Cannot create .env.prod"
        exit 1
    fi
fi

echo ""
echo "📦 Deployment Options:"
echo "1. Deploy using pre-built images from GitHub Container Registry"
echo "2. Build and deploy locally"
echo ""
read -p "Select option (1 or 2): " deploy_option

if [ "$deploy_option" = "1" ]; then
    echo ""
    echo "🐳 Deploying with pre-built images..."
    
    # Check if user is logged in to GHCR
    echo "ℹ️  Make sure you're logged in to GitHub Container Registry"
    echo "   If not, run: echo \$GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin"
    echo ""
    read -p "Press Enter to continue..."
    
    # Pull and start containers
    docker-compose -f docker-compose.prod.yml pull
    docker-compose -f docker-compose.prod.yml up -d
    
elif [ "$deploy_option" = "2" ]; then
    echo ""
    echo "🔨 Building and deploying locally..."
    
    # Build images
    echo "Building Docker images..."
    docker-compose -f docker-compose.yml build
    
    # Deploy with production config
    docker-compose -f docker-compose.prod.yml up -d
    
else
    echo "❌ Invalid option selected."
    exit 1
fi

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📊 Checking service status..."
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🎉 AgentGPT is now running!"
echo ""
echo "Access your application at:"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:8000"
echo "  API Docs: http://localhost:8000/api/docs"
echo ""
echo "📝 Useful commands:"
echo "  View logs: docker-compose -f docker-compose.prod.yml logs -f"
echo "  Stop services: docker-compose -f docker-compose.prod.yml down"
echo "  Restart services: docker-compose -f docker-compose.prod.yml restart"
echo ""
echo "For more information, see docs/DEPLOYMENT.md"
