#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          React Document Show - Quick Start                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if OpenSearch is running
echo "1️⃣  Checking OpenSearch..."
if curl -s http://localhost:9200 > /dev/null 2>&1; then
    echo "   ✅ OpenSearch is running"
else
    echo "   ❌ OpenSearch not running"
    echo "   Starting OpenSearch..."
    docker-compose -f docker-compose.opensearch.yml up -d
    sleep 10
fi

# Get a document ID
echo ""
echo "2️⃣  Getting document IDs..."
DOC_ID=$(curl -s "http://localhost:9200/test_documents/_search?size=1" | jq -r '.hits.hits[0]._id')

if [ -z "$DOC_ID" ] || [ "$DOC_ID" = "null" ]; then
    echo "   ⚠️  No documents found. Creating test document..."
    
    RESPONSE=$(curl -s -X POST "http://localhost:9200/test_documents/_doc" \
      -H 'Content-Type: application/json' \
      -d '{
        "title": "React Test Document",
        "content": "This is a test document for the React show page. It contains sample content to demonstrate the document viewer functionality.",
        "status": "signed"
      }')
    
    DOC_ID=$(echo $RESPONSE | jq -r '._id')
    echo "   ✅ Created test document: $DOC_ID"
else
    echo "   ✅ Found document: $DOC_ID"
fi

# Build JavaScript if needed
echo ""
echo "3️⃣  Building JavaScript..."
cd /Users/vkuzm/RubymineProjects/coh/mpa
if [ -f "app/assets/builds/application.js" ]; then
    echo "   ✅ JavaScript already built"
else
    echo "   Building..."
    npm run build > /dev/null 2>&1
    echo "   ✅ JavaScript built"
fi

# Start Rails server info
echo ""
echo "4️⃣  Rails Server"
echo "   Start with: rails server"
echo ""

# Show URLs
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    URLs to Test                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📄 Document Show Page:"
echo "   http://localhost:3000/documents/$DOC_ID"
echo ""
echo "🔌 API Endpoint:"
echo "   http://localhost:3000/api/documents/$DOC_ID"
echo ""
echo "🔍 Search Page:"
echo "   http://localhost:3000/search"
echo ""

# Test API
echo "5️⃣  Testing API..."
sleep 2
API_RESPONSE=$(curl -s "http://localhost:3000/api/documents/$DOC_ID" 2>/dev/null)

if [ $? -eq 0 ] && [ ! -z "$API_RESPONSE" ]; then
    echo "   ✅ API is responding"
    echo ""
    echo "📋 Test commands:"
    echo ""
    echo "# Test API directly:"
    echo "curl http://localhost:3000/api/documents/$DOC_ID | jq '.'"
    echo ""
    echo "# Test in browser:"
    echo "open http://localhost:3000/documents/$DOC_ID"
else
    echo "   ⚠️  Rails server not running"
    echo "   Start with: rails server"
fi

echo ""
echo "✅ Ready! Open http://localhost:3000/documents/$DOC_ID"
echo ""
