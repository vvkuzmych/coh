#!/bin/bash

# Start Rails server with correct Node version
# 
# Usage: ./start-server.sh
# 
# This script ensures:
# - Node 20.18.1 is active
# - JavaScript assets are built
# - Rails server starts correctly

cd "$(dirname "$0")"

# Load nvm and use Node 20
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 20.18.1 >/dev/null 2>&1

echo "================================"
echo "  COH Rails Server"
echo "================================"
echo "✅ Node: $(node -v)"
echo "✅ Ruby: $(ruby --version | cut -d' ' -f1-2)"
echo "✅ Rails: $(bundle exec rails -v)"
echo ""
echo "🚀 Starting server..."
echo "📍 Visit: http://localhost:3000"
echo "📍 Engine: http://localhost:3000/user_management"
echo ""
echo "Press Ctrl+C to stop"
echo "================================"
echo ""

# Start Rails server
bin/rails server
