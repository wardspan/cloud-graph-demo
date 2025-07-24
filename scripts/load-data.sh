#!/bin/bash

# Manual data loading script for Cloud Threat Graph Lab
echo "🔄 Loading data manually into Neo4j..."

# Check if Neo4j is running
if ! docker-compose ps neo4j | grep -q "Up"; then
    echo "❌ Neo4j container is not running. Start it first with: docker-compose up -d neo4j"
    exit 1
fi

# Wait for Neo4j to be ready
echo "⏳ Waiting for Neo4j to be ready..."
sleep 10

# Load the simple data
echo "📊 Loading simple data set..."
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity -f /var/lib/neo4j/import/init.cypher

# Verify data loaded
echo "✅ Verifying data load..."
NODE_COUNT=$(docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity "MATCH (n) RETURN count(n) as count;" --format plain | tail -n 1)

if [ "$NODE_COUNT" -gt 0 ]; then
    echo "🎉 Success! Loaded $NODE_COUNT nodes."
    echo "🔗 Neo4j Browser: http://localhost:7474 (neo4j/cloudsecurity)"
    echo "📊 Dashboard: http://localhost:3000"
else
    echo "❌ Data loading failed. Check logs:"
    echo "   docker-compose logs data-loader"
fi