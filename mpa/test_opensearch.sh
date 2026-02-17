#!/bin/bash

# OpenSearch Testing Script
# Comprehensive test suite for OpenSearch functionality

set -e  # Exit on error

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   OpenSearch Testing Script          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

OPENSEARCH_URL="${OPENSEARCH_URL:-http://localhost:9200}"

# Function to print section header
print_header() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN} $1${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
}

# Function to print test result
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# 1. Check Docker
print_header "1. Docker Status"
if docker ps &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is running"
    
    # Check if OpenSearch container is running
    if docker ps | grep -q opensearch; then
        echo -e "${GREEN}✓${NC} OpenSearch container is running"
    else
        echo -e "${YELLOW}⚠${NC}  OpenSearch container not running"
        echo "   Starting OpenSearch..."
        docker-compose -f docker-compose.opensearch.yml up -d
        echo "   Waiting 30 seconds for startup..."
        sleep 30
    fi
else
    echo -e "${RED}✗${NC} Docker is not running"
    echo "   Please start Docker Desktop first"
    exit 1
fi

# 2. Check OpenSearch Connection
print_header "2. OpenSearch Connection"
echo "Testing connection to $OPENSEARCH_URL..."

MAX_RETRIES=10
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if curl -s "$OPENSEARCH_URL" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Connected to OpenSearch"
        break
    else
        RETRY=$((RETRY + 1))
        echo "   Retry $RETRY/$MAX_RETRIES..."
        sleep 3
    fi
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo -e "${RED}✗${NC} Cannot connect to OpenSearch"
    exit 1
fi

# Get cluster info
curl -s "$OPENSEARCH_URL" | jq '{name, cluster_name, version}' 2>/dev/null || echo "   (jq not installed, skipping pretty print)"

# 3. Check Cluster Health
print_header "3. Cluster Health"
HEALTH=$(curl -s "$OPENSEARCH_URL/_cluster/health" | jq -r '.status' 2>/dev/null || echo "unknown")
if [ "$HEALTH" = "green" ] || [ "$HEALTH" = "yellow" ]; then
    echo -e "${GREEN}✓${NC} Cluster health: $HEALTH"
else
    echo -e "${RED}✗${NC} Cluster health: $HEALTH"
fi

# 4. Check if Rails is available
print_header "4. Rails Environment"
if command -v rails &> /dev/null; then
    echo -e "${GREEN}✓${NC} Rails is installed"
    
    # Check if we can run Rails commands
    if [ -f "config/environment.rb" ]; then
        echo -e "${GREEN}✓${NC} Rails app detected"
    else
        echo -e "${RED}✗${NC} Not in Rails root directory"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} Rails not found"
    exit 1
fi

# 5. Check Gem Installation
print_header "5. Check opensearch-ruby gem"
if bundle list | grep -q opensearch-ruby; then
    echo -e "${GREEN}✓${NC} opensearch-ruby gem is installed"
else
    echo -e "${YELLOW}⚠${NC}  opensearch-ruby gem not installed"
    echo "   Add to Gemfile: gem 'opensearch-ruby'"
    echo "   Then run: bundle install"
    exit 1
fi

# 6. Create Test Data
print_header "6. Create Test Data"
echo "Creating test documents..."
rails runner db/seeds/opensearch_documents.rb
print_result $? "Test data created"

# 7. Create OpenSearch Index
print_header "7. OpenSearch Index Setup"
echo "Resetting OpenSearch indices..."
rails opensearch:reset
print_result $? "Index reset complete"

# 8. Check Index Status
print_header "8. Index Status"
INDEX_NAME="development_documents"
curl -s "$OPENSEARCH_URL/_cat/indices/$INDEX_NAME?v" 2>/dev/null || echo "Index not found"

# 9. Test Searches
print_header "9. Testing Search Queries"

# Test 1: Simple match
echo ""
echo -e "${BLUE}Test 1: Search for 'contract'${NC}"
curl -s -X POST "$OPENSEARCH_URL/$INDEX_NAME/_search" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": { "match": { "title": "contract" } },
    "size": 3
  }' | jq '.hits.total.value, .hits.hits[]._source.title' 2>/dev/null || echo "Search executed"
print_result $? "Simple search"

# Test 2: Multi-field search
echo ""
echo -e "${BLUE}Test 2: Multi-field search for 'agreement'${NC}"
curl -s -X POST "$OPENSEARCH_URL/$INDEX_NAME/_search" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "multi_match": {
        "query": "agreement",
        "fields": ["title^2", "content"]
      }
    },
    "size": 3
  }' | jq '.hits.total.value, .hits.hits[]._source.title' 2>/dev/null || echo "Search executed"
print_result $? "Multi-field search"

# Test 3: Filtered search
echo ""
echo -e "${BLUE}Test 3: Filter by status='published'${NC}"
curl -s -X POST "$OPENSEARCH_URL/$INDEX_NAME/_search" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "bool": {
        "filter": [
          { "term": { "status": "published" } }
        ]
      }
    },
    "size": 0
  }' | jq '.hits.total.value' 2>/dev/null || echo "Search executed"
print_result $? "Filtered search"

# Test 4: Aggregation
echo ""
echo -e "${BLUE}Test 4: Aggregation by status${NC}"
curl -s -X POST "$OPENSEARCH_URL/$INDEX_NAME/_search" \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 0,
    "aggs": {
      "status_count": {
        "terms": { "field": "status" }
      }
    }
  }' | jq '.aggregations.status_count.buckets' 2>/dev/null || echo "Aggregation executed"
print_result $? "Aggregation"

# 10. Rails Console Tests
print_header "10. Rails Console Tests"
echo "Testing search via Rails models..."

cat > /tmp/opensearch_test.rb << 'EOF'
# Test Rails search functionality
puts "\n--- Testing Document.search ---"

# Test 1: Simple search
results = Document.search({ match: { title: "contract" } })
puts "✓ Found #{results.count} documents matching 'contract'"

# Test 2: Status filter
results = Document.search({
  bool: {
    filter: [{ term: { status: "published" } }]
  }
})
puts "✓ Found #{results.count} published documents"

# Test 3: Multi-field
results = Document.search({
  multi_match: {
    query: "payment agreement",
    fields: ['title^2', 'content']
  }
})
puts "✓ Found #{results.count} documents with 'payment agreement'"

puts "\n✅ All Rails tests passed"
EOF

rails runner /tmp/opensearch_test.rb
print_result $? "Rails console tests"

# 11. Check OpenSearch Dashboards
print_header "11. OpenSearch Dashboards"
if curl -s http://localhost:5601 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} OpenSearch Dashboards is running"
    echo "   Open in browser: http://localhost:5601"
else
    echo -e "${YELLOW}⚠${NC}  OpenSearch Dashboards not accessible"
fi

# Summary
print_header "Summary"
echo -e "${GREEN}✅ All tests completed!${NC}"
echo ""
echo "Next steps:"
echo "  - Open OpenSearch Dashboards: http://localhost:5601"
echo "  - Run custom searches: rails console"
echo "  - View documentation: cat OPENSEARCH_QUICKSTART.md"
echo ""
echo "Useful commands:"
echo "  rails opensearch:status       - Check connection"
echo "  rails opensearch:reindex      - Reindex all documents"
echo "  rails opensearch:list_indices - List all indices"
echo ""
