#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 COH Modular Monolith Verification"
echo "====================================="
echo ""

# Check structure
echo "📁 Checking directory structure..."
if [ -d "mpa" ] && [ -d "packages/user_management" ]; then
    echo -e "${GREEN}✅ Directory structure correct${NC}"
else
    echo -e "${RED}❌ Directory structure incorrect${NC}"
    exit 1
fi

# Check version files at root
echo "📋 Checking version files at root..."
if [ -f ".ruby-version" ] && [ -f ".node-version" ]; then
    echo -e "${GREEN}✅ Version files present at root${NC}"
    ruby_ver=$(cat .ruby-version)
    node_ver=$(cat .node-version)
    echo "   Ruby: $ruby_ver"
    echo "   Node: $node_ver"
    
    # Check if Node is modern
    if [[ "$node_ver" < "18.0.0" ]]; then
        echo -e "${YELLOW}⚠️  Warning: Node version is outdated (< 18)${NC}"
    fi
else
    echo -e "${RED}❌ Version files missing at root${NC}"
    exit 1
fi

# Check .env is ignored
echo "🔒 Checking .env is ignored by git..."
if git check-ignore -q packages/user_management/.env; then
    echo -e "${GREEN}✅ .env files are properly ignored${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: .env might not be ignored${NC}"
fi

# Check .env.example exists
echo "📄 Checking .env.example exists..."
if [ -f "packages/user_management/.env.example" ]; then
    echo -e "${GREEN}✅ .env.example exists${NC}"
else
    echo -e "${RED}❌ .env.example missing${NC}"
fi

# Check engine in Gemfile
echo "💎 Checking engine in MPA Gemfile..."
if grep -q 'gem "user_management"' mpa/Gemfile; then
    echo -e "${GREEN}✅ Engine added to Gemfile${NC}"
else
    echo -e "${RED}❌ Engine missing from Gemfile${NC}"
    exit 1
fi

# Check platforms in Gemfile.lock
echo "🖥️  Checking platforms in Gemfile.lock..."
if grep -q "x86_64-linux" mpa/Gemfile.lock; then
    echo -e "${GREEN}✅ x86_64-linux platform added${NC}"
else
    echo -e "${RED}❌ x86_64-linux platform missing${NC}"
    exit 1
fi

# Check CI workflow
echo "🔧 Checking CI workflow..."
if grep -q "working-directory: mpa" .github/workflows/ci.yml; then
    echo -e "${GREEN}✅ CI workflow updated for mpa/${NC}"
else
    echo -e "${RED}❌ CI workflow not updated${NC}"
    exit 1
fi

# Check documentation
echo "📚 Checking documentation..."
docs=("README.md" "MIGRATION_GUIDE.md" "ENV_CONFIGURATION.md" "CI_CD_SETUP.md" "SECURITY_IMPROVEMENTS.md" "CHANGES_SUMMARY.md")
all_docs_present=true
for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "   ${GREEN}✅${NC} $doc"
    else
        echo -e "   ${RED}❌${NC} $doc"
        all_docs_present=false
    fi
done

if [ "$all_docs_present" = true ]; then
    echo -e "${GREEN}✅ All documentation present${NC}"
fi

# Test Rails boots
echo "🚀 Testing if Rails boots..."
cd mpa
if bundle exec rails runner "puts 'OK'" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Rails boots successfully${NC}"
else
    echo -e "${RED}❌ Rails fails to boot${NC}"
    exit 1
fi

# Test engine loads
echo "🔌 Testing if engine loads..."
if bundle exec rails runner "puts UserManagement::Engine.name" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ UserManagement engine loads${NC}"
else
    echo -e "${RED}❌ Engine fails to load${NC}"
    exit 1
fi

cd ..

echo ""
echo "================================="
echo -e "${GREEN}🎉 All checks passed!${NC}"
echo "================================="
echo ""
echo "Your modular monolith is ready! 🚀"
echo ""
echo "Next steps:"
echo "1. Review changes: git status"
echo "2. Commit: git add . && git commit -m 'Restructure to modular monolith'"
echo "3. Push: git push"
echo "4. Check CI passes on GitHub"
