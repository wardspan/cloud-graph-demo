#!/bin/bash

echo "🔄 Cloud Threat Graph Lab - Environment Reset"
echo "============================================="

# Confirm reset
read -p "⚠️ This will reset all discovered assets and return to Phase 1 baseline. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Reset cancelled"
    exit 1
fi

echo "🧹 Resetting environment to Phase 1 baseline..."

# Stop containers
echo "⏹️ Stopping containers..."
docker-compose down

# Clean Neo4j data (keep baseline)
echo "🗃️ Cleaning Neo4j data..."
if [ -d "./neo4j/data" ]; then
    sudo rm -rf ./neo4j/data/databases/neo4j/*
    sudo rm -rf ./neo4j/data/transactions/neo4j/*
    echo "   Neo4j data cleaned"
fi

# Clean LocalStack data
echo "🗃️ Cleaning LocalStack data..."
docker volume rm cloud-graph-demo_localstack-data 2>/dev/null || true

# Restart services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to initialize..."
sleep 30

# Wait for Neo4j specifically
echo "⏳ Waiting for Neo4j to be ready..."
while ! curl -s http://localhost:7474 > /dev/null; do
    echo "   Waiting for Neo4j..."
    sleep 5
done

# Wait for data loader to complete
echo "⏳ Waiting for baseline data to load..."
while docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "cloud-threat-loader.*Up"; do
    echo "   Loading baseline data..."
    sleep 10
done

echo ""
echo "✅ Environment reset complete!"
echo ""
echo "📊 Current state:"
echo "   - Phase 1 & 2 baseline scenarios loaded"
echo "   - Phase 3 discovery schemas ready"
echo "   - Asset discovery ready to run"
echo ""
echo "🎯 Next steps:"
echo "   1. Open dashboard: http://localhost:3000"
echo "   2. Click 'Discover Infrastructure' to start Phase 3"
echo "   3. Or run: ./scripts/start-discovery-simulation.sh"
echo ""
echo "💡 The lab is now in 'pre-discovery' state, ready to demonstrate"
echo "   how asset discovery reveals hidden infrastructure relationships."