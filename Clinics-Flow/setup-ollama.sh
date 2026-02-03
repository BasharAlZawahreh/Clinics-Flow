#!/bin/bash
# Setup script for Ollama Hybrid AI

set -e

echo "🚀 Setting up Ollama Hybrid AI for JoClinicsFlows..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose."
    exit 1
fi

echo "✅ Docker and Docker Compose found"
echo ""

# Check for API keys
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  Warning: OPENAI_API_KEY not set"
    echo "   Set it with: export OPENAI_API_KEY=your-key"
    echo "   OpenAI fallback will not work"
    echo ""
fi

# Build AI Router
echo "🔨 Building AI Router Service..."
cd ai-router
npm install
npm run build
cd ..

echo "✅ AI Router built successfully"
echo ""

# Start Ollama services
echo "🐳 Starting Ollama services..."
docker-compose -f docker-compose.ollama.yml up -d

echo "⏳ Waiting for Ollama to be ready..."
sleep 10

# Pull models
echo "📥 Downloading AI models (this may take a few minutes)..."
docker-compose -f docker-compose.ollama.yml exec -T ollama ollama pull qwen2.5:7b || echo "⚠️  Failed to pull qwen2.5:7b"
docker-compose -f docker-compose.ollama.yml exec -T ollama ollama pull mistral:7b || echo "⚠️  Failed to pull mistral:7b"

echo ""
echo "✅ Setup complete!"
echo ""
echo "📊 Services:"
echo "   • Ollama API:      http://localhost:11434"
echo "   • Web UI:          http://localhost:3005"
echo "   • AI Router:       http://localhost:3006"
echo ""
echo "🧪 Test with:"
echo "   curl -X POST http://localhost:3006/generate \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{"task":"sentiment_analysis","content":"Great service!","language":"en"}'"
echo ""
echo "📖 Documentation: OLLAMA_STRATEGY.md"
echo ""
