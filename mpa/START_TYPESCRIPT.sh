#!/bin/bash

# Start TypeScript Demo
# Quick script to launch TypeScript component in Rails

set -e

echo ""
echo "🚀 Starting TypeScript Demo"
echo "======================================"
echo ""

# Check if in correct directory
if [ ! -f "package.json" ]; then
  echo "❌ Error: Run from Rails root directory"
  exit 1
fi

# Step 1: Install dependencies
echo "1️⃣  Checking dependencies..."
if [ ! -d "node_modules" ]; then
  echo "   📦 Installing npm packages..."
  npm install
else
  echo "   ✅ Dependencies OK"
fi
echo ""

# Step 2: Type check
echo "2️⃣  Running type check..."
npm run type-check
if [ $? -eq 0 ]; then
  echo "   ✅ No TypeScript errors"
else
  echo "   ❌ Type errors found - fix them first!"
  exit 1
fi
echo ""

# Step 3: Build
echo "3️⃣  Building JavaScript with TypeScript..."
npm run build
if [ $? -eq 0 ]; then
  echo "   ✅ Build successful"
else
  echo "   ❌ Build failed"
  exit 1
fi
echo ""

# Step 4: Check if Rails is running
echo "4️⃣  Checking Rails server..."
if lsof -i:3000 > /dev/null 2>&1; then
  echo "   ✅ Rails already running on port 3000"
  echo ""
  echo "======================================"
  echo "✅ TypeScript Demo Ready!"
  echo "======================================"
  echo ""
  echo "🌐 Open in browser:"
  echo "   http://localhost:3000/typescript-demo"
  echo ""
  echo "📝 Routes:"
  echo "   • http://localhost:3000/typescript-demo"
  echo "   • http://localhost:3000/documents/[ID]"
  echo "   • http://localhost:3000/search"
  echo ""
  echo "🔍 To verify TypeScript:"
  echo "   1. Open DevTools → Console"
  echo "   2. Check for: '✅ TypeScript component loaded'"
  echo "   3. View Sources → webpack:// → HelloTypeScript.tsx"
  echo ""
else
  echo "   ⚠️  Rails not running, starting now..."
  echo ""
  echo "======================================"
  echo "✅ Starting Rails Server"
  echo "======================================"
  echo ""
  echo "🌐 Server will start at: http://localhost:3000"
  echo ""
  echo "📝 After server starts, visit:"
  echo "   http://localhost:3000/typescript-demo"
  echo ""
  echo "Press Ctrl+C to stop the server"
  echo ""
  
  # Start Rails
  rails server
fi
