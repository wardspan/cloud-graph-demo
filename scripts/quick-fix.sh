#!/bin/bash

echo "🔧 Quick fix - Adding missing relationships manually..."

# Copy the manual fix script to the container and run it
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity "
// Quick manual relationship creation
MATCH (sarah:User {name: 'Sarah Chen'})
MATCH (s3:Service {name: 'company-sensitive-data'})
MERGE (sarah)-[:CAN_ACCESS {method: 'Through assumed roles', created: datetime()}]->(s3);

MATCH (emma:User {name: 'Emma Watson'})
MATCH (s3:Service {name: 'company-sensitive-data'})
MERGE (emma)-[:CAN_ACCESS {method: 'Through CI/CD pipeline', created: datetime()}]->(s3);

// Test the fix
MATCH (u:User)-[r:CAN_ACCESS]->(s:Service)
RETURN u.name as User, s.name as Service, r.method as Method;
"

echo "✅ Quick fix applied! Test your queries now."