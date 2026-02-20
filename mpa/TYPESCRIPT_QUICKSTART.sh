#!/bin/bash

# TypeScript Quick Start for Rails + React
# Auto-install and setup TypeScript

set -e  # Exit on error

echo "🚀 TypeScript Quick Start"
echo "=========================="
echo

# 1. Install dependencies
echo "📦 Installing TypeScript dependencies..."
npm install
echo "✅ Dependencies installed"
echo

# 2. Type check
echo "🔍 Running type check..."
npm run type-check
if [ $? -eq 0 ]; then
  echo "✅ No type errors found!"
else
  echo "⚠️  Type errors detected (see above)"
fi
echo

# 3. Build
echo "🔨 Building JavaScript/TypeScript..."
npm run build
echo "✅ Build complete"
echo

# 4. Summary
echo "=========================="
echo "✅ TypeScript setup complete!"
echo
echo "📁 Created files:"
echo "   - tsconfig.json"
echo "   - app/javascript/components/DocumentShow.tsx"
echo "   - app/javascript/components/ExampleTypescriptComponent.tsx"
echo "   - app/javascript/types/document.ts"
echo
echo "🎯 Next steps:"
echo "   1. Start Rails server: rails s"
echo "   2. Create new .tsx components in app/javascript/components/"
echo "   3. Run type check: npm run type-check"
echo "   4. Read TYPESCRIPT_SETUP.md for examples"
echo
echo "💡 You can use BOTH .jsx and .tsx files together!"
echo
