#!/bin/bash
# Copy Prisma Client to Web App
# This script copies the generated Prisma client to the correct location for Vercel build

echo "🔨 Copying Prisma client to web app..."

# Navigate to scripts directory
cd /home/bashar/.openclaw/workspace/Clinics-Flow/scripts

# Check if Prisma client exists in database
if [ -f "../packages/database/node_modules/@prisma/client/index.js" ]; then
    echo "✅ Prisma client found"
    
    # Navigate to web app
    cd ../apps/web
    
    # Copy Prisma client
    echo "📋 Copying Prisma client..."
    mkdir -p node_modules/@prisma
    cp -r ../packages/database/node_modules/@prisma/client/* node_modules/@prisma/
    
    # Verify copy
    if [ -f "node_modules/@prisma/client/index.js" ]; then
        echo "✅ Prisma client copied successfully"
    else
        echo "❌ Copy failed"
        exit 1
    fi
else
    echo "❌ Prisma client not found in database directory"
    echo "💡 Please run: cd ../packages/database && npx prisma generate"
    exit 1
fi

echo ""
echo "✅ Prisma client is now available in apps/web/node_modules/@prisma/client/"
echo "📝 Next.js build should find it correctly during Vercel deployment"
