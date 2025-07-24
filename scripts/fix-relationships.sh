#!/bin/bash

echo "🔧 Fixing missing relationships..."

# Run the relationship fix script
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity -f /var/lib/neo4j/import/fix-relationships.cypher

echo "✅ Relationships should now be fixed!"
echo "🧪 Test with these queries:"
echo ""
echo "MATCH (u:User)-[r:CAN_ACCESS]->(s:Service) RETURN u.name, s.name, r.method;"
echo "MATCH path = (u:User)-[*1..2]->(s:Service) WHERE u.access_level = 'developer' RETURN u.name, s.name, length(path);"