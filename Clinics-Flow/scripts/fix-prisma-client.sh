#!/bin/bash
# Fix Prisma Client Location for Vercel Build
# Copy Prisma client to correct location before Next.js build

echo "🔨 Prisma Client Fix for Vercel..."

# Navigate to web app directory
cd /home/bashar/.openclaw/workspace/Clinics-Flow/apps/web

# Check if Prisma client exists in database
if [ -f "../packages/database/node_modules/.prisma/client/index.js" ]; then
    echo "✅ Prisma client found in database directory"
    
    # Copy Prisma client to web app's node_modules
    echo "📋 Copying Prisma client to web app..."
    mkdir -p node_modules/.prisma
    cp -r ../packages/database/node_modules/.prisma/client/* node_modules/.prisma/
    
    # Verify copy
    if [ -f "node_modules/.prisma/client/index.js" ]; then
        echo "✅ Prisma client copied successfully to web/node_modules/.prisma/client/"
    else
        echo "❌ Copy failed - client not found after copy"
        exit 1
    fi
else
    echo "❌ Prisma client not generated in database directory"
    echo "💡 Please run: cd ../packages/database && npx prisma generate"
    exit 1
fi

echo ""
echo "✅ Prisma client is now available at: node_modules/.prisma/client/"
echo "📝 Next.js build should find it correctly during Vercel deployment"
