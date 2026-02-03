#!/bin/bash
# Prisma Client Generation Script
# Run this before Vercel deployment

echo "🔨 Generating Prisma client..."

# Generate Prisma client from schema
cd packages/database
npx prisma generate

echo "✅ Prisma client generated successfully!"

# Generate Prisma client for API
cd ../apps/api
npx prisma generate

echo "✅ API Prisma client generated!"

# Verify generation
if [ -f "node_modules/.prisma/client/index.js" ]; then
    echo "✅ Prisma client found at: node_modules/.prisma/client/"
else
    echo "❌ Prisma client NOT found - check for errors"
    exit 1
fi

echo ""
echo "✅ Ready for deployment!"
echo "📝 Next steps:"
echo "  1. Push to GitHub"
echo "  2. Trigger Vercel deployment"
echo "  3. Verify Prisma client is generated"
