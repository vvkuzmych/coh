#!/bin/bash

echo "🔧 Fixing Node.js version..."

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node 20
nvm use 20.18.1

# Verify
echo "✅ Node version: $(node -v)"
echo "✅ npm version: $(npm -v)"

echo ""
echo "To make this permanent in your current terminal, run:"
echo "  source ~/.zshrc"
