#!/bin/bash

# OpenSearch Setup Script
# One-command setup for OpenSearch integration

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   OpenSearch Setup Script            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check Docker
echo -e "${GREEN}[1/7]${NC} Checking Docker..."
if ! docker ps &> /dev/null; then
    echo -e "${YELLOW}⚠${NC}  Docker is not running. Starting Docker..."
    open -a Docker
    echo "   Waiting for Docker to start (30 seconds)..."
    sleep 30
fi
echo -e "${GREEN}✓${NC} Docker is running"

# Step 2: Start OpenSearch
echo ""
echo -e "${GREEN}[2/7]${NC} Starting OpenSearch containers..."
docker-compose -f docker-compose.opensearch.yml up -d
echo "   Waiting for OpenSearch to be ready (30 seconds)..."
sleep 30

# Step 3: Check connection
echo ""
echo -e "${GREEN}[3/7]${NC} Checking OpenSearch connection..."
MAX_RETRIES=10
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:9200 > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Connected to OpenSearch"
        break
    fi
    RETRY=$((RETRY + 1))
    echo "   Retry $RETRY/$MAX_RETRIES..."
    sleep 3
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo -e "${YELLOW}⚠${NC}  Cannot connect to OpenSearch"
    echo "   Please check: docker logs opensearch"
    exit 1
fi

# Step 4: Check gem
echo ""
echo -e "${GREEN}[4/7]${NC} Checking opensearch-ruby gem..."
if bundle list | grep -q opensearch-ruby; then
    echo -e "${GREEN}✓${NC} Gem is installed"
else
    echo -e "${YELLOW}⚠${NC}  Adding opensearch-ruby to Gemfile..."
    echo "" >> Gemfile
    echo "# OpenSearch integration" >> Gemfile
    echo 'gem "opensearch-ruby"' >> Gemfile
    
    echo "   Running bundle install..."
    bundle install
fi

# Step 5: Uncomment initializer
echo ""
echo -e "${GREEN}[5/7]${NC} Setting up OpenSearch initializer..."
if grep -q "# require 'opensearch'" config/initializers/opensearch.rb 2>/dev/null; then
    echo "   Uncommenting initializer..."
    sed -i.bak 's/# require/require/g' config/initializers/opensearch.rb
    sed -i.bak 's/# OPENSEARCH_CLIENT/OPENSEARCH_CLIENT/g' config/initializers/opensearch.rb
    sed -i.bak 's/#   /  /g' config/initializers/opensearch.rb
    rm config/initializers/opensearch.rb.bak 2>/dev/null || true
fi
echo -e "${GREEN}✓${NC} Initializer configured"

# Step 6: Create test data
echo ""
echo -e "${GREEN}[6/7]${NC} Creating test documents..."
if rails runner db/seeds/opensearch_documents.rb 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Test data created"
else
    echo -e "${YELLOW}⚠${NC}  Could not create test data (might need to setup database first)"
fi

# Step 7: Setup OpenSearch index
echo ""
echo -e "${GREEN}[7/7]${NC} Creating OpenSearch index..."
if rails opensearch:reset 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Index created and documents indexed"
else
    echo -e "${YELLOW}⚠${NC}  Could not create index"
fi

# Done
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Setup Complete! 🎉           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Services:"
echo "  • OpenSearch:           http://localhost:9200"
echo "  • OpenSearch Dashboards: http://localhost:5601"
echo ""
echo "Next steps:"
echo "  1. Test search:    rails console"
echo "                     > Document.search({ match: { title: 'contract' } })"
echo ""
echo "  2. Run tests:      ./test_opensearch.sh"
echo ""
echo "  3. View docs:      cat OPENSEARCH_QUICKSTART.md"
echo ""
echo "Useful commands:"
echo "  rails opensearch:status       # Check status"
echo "  rails opensearch:reindex      # Reindex all"
echo "  rails opensearch:test_search  # Run test search"
echo ""
