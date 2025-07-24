#!/bin/bash

echo "🗺️ Cloud Threat Graph Lab - Asset Discovery Simulation"
echo "======================================================="

# Check if services are running
echo "🔍 Checking service status..."

# Check Neo4j
if ! curl -s http://localhost:7474 > /dev/null; then
    echo "❌ Neo4j is not running. Please start with: docker-compose up -d"
    exit 1
fi

# Check LocalStack
if ! curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo "❌ LocalStack is not running. Please start with: docker-compose up -d"
    exit 1
fi

# Check Cartography container
if ! docker ps --format "table {{.Names}}" | grep -q "cloud-threat-cartography"; then
    echo "❌ Cartography container is not running. Please start with: docker-compose up -d"
    exit 1
fi

echo "✅ All services are running!"
echo ""

# Trigger asset discovery
echo "🚀 Starting asset discovery simulation..."
echo "This will simulate a Cartography-style progressive discovery workflow"
echo ""

# Call the Cartography container's discovery API
if curl -s -X POST http://localhost:8080/discover > /dev/null 2>&1; then
    echo "✅ Discovery simulation triggered via API"
else
    echo "⚠️ API not available, triggering container directly..."
    docker exec cloud-threat-cartography python3 /opt/cartography/simulate-discovery.py
fi

echo ""
echo "🎯 Discovery simulation complete!"
echo ""
echo "📊 Next steps:"
echo "   1. Open the dashboard: http://localhost:3000"
echo "   2. Check the 'Asset Discovery' panel"
echo "   3. Explore the new scenarios: 'Real-World Asset Discovery Attack Path' and 'Cross-Cloud Infrastructure Attack'"
echo "   4. Run Neo4j Browser queries to see discovered assets:"
echo "      MATCH (n) WHERE n.discovered_via_cartography = true RETURN n LIMIT 25"
echo ""
echo "💡 The simulation demonstrates how security teams use automated tools like Cartography"
echo "   to discover cloud infrastructure and identify hidden attack paths."