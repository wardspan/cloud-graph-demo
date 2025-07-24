#!/bin/bash

echo "🔄 Reloading fresh data into Neo4j..."

# Clear all existing data and reload
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity "
MATCH (n) DETACH DELETE n;
" && echo "✅ Existing data cleared"

# Load fresh data
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity -f /var/lib/neo4j/import/init.cypher && echo "✅ Fresh data loaded"

# Test basic queries
echo "🧪 Testing basic connectivity..."

echo "📊 Node counts:"
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity "
MATCH (n) RETURN labels(n)[0] as NodeType, count(n) as Count ORDER BY Count DESC;
"

echo "🔗 Relationship counts:"
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity "
MATCH ()-[r]->() RETURN type(r) as RelType, count(r) as Count ORDER BY Count DESC;
"

echo "👤 Users with access levels:"
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity "
MATCH (u:User) WHERE u.access_level IS NOT NULL RETURN u.name, u.access_level ORDER BY u.access_level;
"

echo "🎯 Direct user→service paths:"
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity "
MATCH (u:User)-[r:CAN_ACCESS]->(s:Service) RETURN u.name, type(r), s.name LIMIT 5;
"

echo "🔄 Reload complete!"