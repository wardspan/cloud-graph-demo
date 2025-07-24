# 🔍 Verification Queries

Run these queries in Neo4j Browser to verify your lab data loaded correctly:

## 1. Check Data Loading
```cypher
// Verify all node types are present
MATCH (n) 
RETURN labels(n)[0] as NodeType, count(n) as Count 
ORDER BY Count DESC
```
**Expected:** Should show Users, Roles, Services, Pods, etc.

## 2. Verify AWS Attack Path
```cypher
// Test the AWS privilege escalation path
MATCH (user:AWSUser {access_level: 'developer'})
MATCH (service:AWSService {contains_pii: true})
RETURN user.name, service.name
```
**Expected:** Should show Sarah Chen and company-sensitive-data

## 3. Check Relationships
```cypher
// Count all relationship types
MATCH ()-[r]->() 
RETURN type(r) as RelationType, count(r) as Count 
ORDER BY Count DESC
```
**Expected:** Should show ASSUMES_ROLE, CAN_ACCESS, MOUNTS_SA, etc.

## 4. Quick Attack Path Test
```cypher
// Simple 2-hop path test
MATCH path = (user:User)-[*1..2]->(service:Service)
WHERE user.access_level = 'developer'
RETURN user.name, service.name, length(path)
LIMIT 5
```
**Expected:** Should show attack paths from developers to services

## 🚨 If queries return no results:
1. Check if docker-compose is running: `docker-compose ps`
2. Restart the data loader: `docker-compose restart data-loader`
3. Check logs: `docker-compose logs data-loader`
4. Manually reload data:
   ```bash
   docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity -f /var/lib/neo4j/import/init.cypher
   ```