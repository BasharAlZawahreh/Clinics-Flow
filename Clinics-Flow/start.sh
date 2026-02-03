#!/bin/bash
# Complete Docker Setup Script for JoClinicsFlows
# One command to run everything!

set -e

echo "🚀 JoClinicsFlows - Complete Docker Setup"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found!${NC}"
    echo "   Install from: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose not found!${NC}"
    echo "   Install from: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose found${NC}"
echo ""

# Check .env file
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    echo "   Creating from .env.example..."
    cp .env.example .env
    echo -e "${YELLOW}   Please edit .env with your actual values!${NC}"
    echo ""
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p logs nginx/ssl

echo ""
echo "🔨 Building and starting services..."
echo "   This may take 5-10 minutes on first run..."
echo ""

# Pull and build
docker-compose pull
docker-compose build

# Start services
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
echo ""

# Wait for postgres
until docker-compose exec -T postgres pg_isready -U joclinics > /dev/null 2>&1; do
    echo -n "🔄 Waiting for PostgreSQL..."
    sleep 2
done
echo -e "${GREEN} Ready!${NC}"

# Wait for Ollama
until curl -f http://localhost:11434/api/tags > /dev/null 2>&1; do
    echo -n "🔄 Waiting for Ollama..."
    sleep 2
done
echo -e "${GREEN} Ready!${NC}"

# Download AI models
echo ""
echo "🧠 Downloading AI models (this will take a few minutes)..."
echo ""

echo "   📥 Downloading Qwen2.5:7b (Arabic support)..."
docker-compose exec -T ollama ollama pull qwen2.5:7b || echo -e "${YELLOW}   ⚠️  Failed to download qwen2.5:7b${NC}"

echo "   📥 Downloading Mistral:7b (English)..."
docker-compose exec -T ollama ollama pull mistral:7b || echo -e "${YELLOW}   ⚠️  Failed to download mistral:7b${NC}"

echo ""
echo "🔄 Waiting for API to be ready..."
sleep 10

# Run database migrations
echo ""
echo "🗄️  Running database migrations..."
docker-compose exec -T api npx prisma migrate deploy || echo -e "${YELLOW}   ⚠️  Migration may have already run${NC}"

echo ""
echo -e "${GREEN}=========================================="
echo "✅ Setup Complete!"
echo "==========================================${NC}"
echo ""
echo "🌐 Your application is running at:"
echo "   • Frontend: http://localhost"
echo "   • API:      http://localhost/v1"
echo "   • AI Router: http://localhost:3006"
echo "   • Ollama:   http://localhost:11434"
echo ""
echo "🧪 Test AI Router:"
echo "   curl -X POST http://localhost:3006/generate \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"task\":\"sentiment_analysis\",\"content\":\"Great service!\",\"language\":\"en\"}'"
echo ""
echo "📊 View logs:"
echo "   docker-compose logs -f"
echo ""
echo "🛑 Stop all services:"
echo "   docker-compose down"
echo ""
echo -e "${YELLOW}⚠️  Important: Edit .env file with your actual API keys!${NC}"
echo ""
