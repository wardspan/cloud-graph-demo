#!/bin/bash

# =====================================================
# CLOUD THREAT GRAPH LAB - PHASE 2 DATA LOADER
# =====================================================
# Loads Phase 2 enhanced scenarios and MITRE integration

echo "🛡️ Cloud Threat Graph Lab - Phase 2 Data Loader"
echo "=================================================="
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose is not installed or not in PATH"
    exit 1
fi

# Check if Neo4j container is running
echo "🔍 Checking Neo4j container status..."
if ! docker-compose ps neo4j | grep -q "Up"; then
    echo "❌ Neo4j container is not running. Please start it first with:"
    echo "   docker-compose up -d neo4j"
    exit 1
fi

echo "✅ Neo4j container is running"
echo ""

# Wait for Neo4j to be ready
echo "⏳ Waiting for Neo4j to be ready..."
for i in {1..12}; do
    if docker-compose exec -T neo4j cypher-shell -u neo4j -p cloudsecurity "RETURN 1;" > /dev/null 2>&1; then
        echo "✅ Neo4j is ready!"
        break
    fi
    if [ $i -eq 12 ]; then
        echo "❌ Neo4j failed to become ready after 60 seconds"
        exit 1
    fi
    echo "   Waiting... ($i/12)"
    sleep 5
done
echo ""

# Load Phase 1 foundation data
echo "📊 Loading Phase 1 foundation data..."
if docker-compose exec -T neo4j cypher-shell -u neo4j -p cloudsecurity -f /var/lib/neo4j/import/init-complete.cypher; then
    echo "✅ Phase 1 data loaded successfully!"
else
    echo "❌ Failed to load Phase 1 data"
    exit 1
fi
echo ""

# Load Phase 2 enhanced scenarios
echo "🏭 Loading Phase 2 enhanced scenarios..."
if docker-compose exec -T neo4j cypher-shell -u neo4j -p cloudsecurity -f /neo4j/phase2-scenarios.cypher; then
    echo "✅ Phase 2 scenarios loaded successfully!"
else
    echo "❌ Failed to load Phase 2 scenarios"
    exit 1
fi
echo ""

# Load MITRE ATT&CK integration
echo "⚔️ Loading MITRE ATT&CK integration..."
if docker-compose exec -T neo4j cypher-shell -u neo4j -p cloudsecurity -f /neo4j/mitre-integration.cypher; then
    echo "✅ MITRE integration completed!"
else
    echo "❌ Failed to load MITRE integration"
    exit 1
fi
echo ""

# Verify data load
echo "🔍 Verifying data load..."
echo "Node types and counts:"
docker-compose exec -T neo4j cypher-shell -u neo4j -p cloudsecurity "MATCH (n) RETURN labels(n)[0] as NodeType, count(n) as Count ORDER BY Count DESC;"
echo ""

echo "📊 Final statistics:"
TOTAL_NODES=$(docker-compose exec -T neo4j cypher-shell -u neo4j -p cloudsecurity "MATCH (n) RETURN count(n) as total;" | tail -n 1 | tr -d '"')
TOTAL_RELATIONSHIPS=$(docker-compose exec -T neo4j cypher-shell -u neo4j -p cloudsecurity "MATCH ()-[r]->() RETURN count(r) as total;" | tail -n 1 | tr -d '"')
MITRE_TECHNIQUES=$(docker-compose exec -T neo4j cypher-shell -u neo4j -p cloudsecurity "MATCH (t:MITRETechnique) RETURN count(t) as total;" | tail -n 1 | tr -d '"')

echo "   • Total Nodes: $TOTAL_NODES"
echo "   • Total Relationships: $TOTAL_RELATIONSHIPS"  
echo "   • MITRE Techniques: $MITRE_TECHNIQUES"
echo "   • Attack Scenarios: 8"
echo ""

echo "🎯 Phase 2 data loading completed successfully!"
echo ""
echo "🚀 Access the lab:"
echo "   • Dashboard: http://localhost:3000"
echo "   • Neo4j Browser: http://localhost:7474 (neo4j/cloudsecurity)"
echo ""
echo "🔥 New Phase 2 features:"
echo "   • 4 additional attack scenarios (Supply Chain, Secrets Sprawl, Serverless, Multi-Cloud)"
echo "   • 25 MITRE ATT&CK techniques with full mappings"
echo "   • Enhanced dashboard with phase badges and MITRE overlay"
echo "   • Mock Cartography data ready for Phase 3 integration"
echo ""
echo "✨ Happy threat hunting!"