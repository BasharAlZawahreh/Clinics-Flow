#!/bin/bash
# Build script for Render deployment (bypasses turbo issues)

set -e

echo "🔨 Building Clinics-Flow for deployment..."
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf apps/web/.next
rm -rf apps/api/dist

# Install all dependencies from root
echo "📦 Installing dependencies..."
npm install

# Build API
echo "🔨 Building API..."
cd apps/api
npm install
npm run build
cd ../..

# Build Web
echo "🔨 Building Web..."
cd apps/web
npm install
npm run build
cd ../..

echo ""
echo "✅ All builds completed successfully!"
echo ""
echo "Ready for Render deployment."
