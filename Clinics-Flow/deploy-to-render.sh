#!/bin/bash
# Deploy Clinics-Flow to Render.com (Free)

set -e

echo "🚀 Deploying Clinics-Flow to Render (Free Hosting)"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Run this from Clinics-Flow root directory"
    exit 1
fi

echo "✅ Found Clinics-Flow project"
echo ""

# Step 1: Create render.yaml for auto-deployment
echo "📝 Creating render.yaml configuration..."
cat > render.yaml << 'EOF'
services:
  # Frontend - Next.js
  - type: web
    name: clinics-flow-web
    env: node
    buildCommand: cd apps/web && npm install && npm run build
    startCommand: cd apps/web && npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: NEXT_PUBLIC_API_URL
        value: https://clinics-flow-api.onrender.com

  # Backend - Node.js API
  - type: web
    name: clinics-flow-api
    env: node
    buildCommand: cd apps/api && npm install
    startCommand: cd apps/api && npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: PORT
        value: 8080
      - key: DATABASE_URL
        fromDatabase:
          name: clinics-flow-db
          property: connectionString
      - key: JWT_SECRET
        generateValue: true
      - key: OPENAI_API_KEY
        sync: false

# PostgreSQL Database
databases:
  - name: clinics-flow-db
    databaseName: clinics_flow
    user: clinics_flow_user
EOF

echo "✅ Created render.yaml"
echo ""

# Step 2: Commit changes
echo "📤 Committing deployment files..."
git add render.yaml DEPLOYMENT.md RENDER_DEPLOYMENT.md
git commit -m "feat: Add Render deployment configuration

- render.yaml for auto-deployment
- Frontend and backend services
- PostgreSQL database
- Free tier optimized" || echo "No changes to commit"

echo "✅ Committed changes"
echo ""

# Step 3: Push to GitHub
echo "⬆️ Pushing to GitHub..."
git push origin main || echo "Already up to date"

echo "✅ Pushed to GitHub"
echo ""

# Step 4: Instructions
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📋 NEXT STEPS - Manual Setup Required"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Create Render account:"
echo "    https://dashboard.render.com/register"
echo ""
echo "2️⃣  Connect your GitHub repository:"
echo "    - Go to: https://dashboard.render.com/new"
echo "    - Click: 'New +' → 'Web Service'"
echo "    - Find: BasharAlZawahreh/Clinics-Flow"
echo "    - Select: render.yaml as blueprint"
echo ""
echo "3️⃣  Set environment variables in Render:"
echo "    - JWT_SECRET: (generate random string)"
echo "    - OPENAI_API_KEY: (your OpenAI key)"
echo "    - NEXT_PUBLIC_API_URL: (after API deploys)"
echo ""
echo "4️⃣  Get database URL:"
echo "    - PostgreSQL → 'External Database URL'"
echo "    - Add to API service environment variables"
echo ""
echo "5️⃣  Wait for deployment (5-10 minutes)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 Your URLs will be:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Frontend: https://clinics-flow-web.onrender.com"
echo "  API:      https://clinics-flow-api.onrender.com"
echo "  Database:  (external connection)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Pro tip: Render free tier spins down after inactivity."
echo "   First load takes ~30 seconds. Consider upgrading for production."
echo ""
