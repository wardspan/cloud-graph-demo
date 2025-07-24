# 🐛 Debug Queries - Run These First

If you're getting no results, run these queries in Neo4j Browser to debug:

## 1. Check if Database is Empty
```cypher
MATCH (n) RETURN count(n) as TotalNodes
```
**Expected:** Should return a number > 0. If 0, data didn't load.

## 2. Check All Nodes (if any exist)
```cypher
MATCH (n) RETURN n LIMIT 10
```
**Expected:** Should show some nodes. If empty, data loading failed.

## 3. Check All Relationships (if any exist)
```cypher
MATCH ()-[r]->() RETURN type(r), count(r) ORDER BY count(r) DESC
```
**Expected:** Should show relationship types and counts.

## 4. Check Specific Node Types
```cypher
MATCH (u:User) RETURN u.name, labels(u) LIMIT 5
UNION
MATCH (r:Role) RETURN r.name, labels(r) LIMIT 5
UNION  
MATCH (s:Service) RETURN s.name, labels(s) LIMIT 5
```

## 🚨 If All Queries Return 0 or Empty:

### Option 1: Manual Data Loading
```bash
# In your terminal:
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity -f /var/lib/neo4j/import/init.cypher
```

### Option 2: Check Data Loader Logs
```bash
docker-compose logs data-loader
```

### Option 3: Restart and Reload
```bash
docker-compose down
docker-compose up -d
# Wait 2 minutes, then check again
```

### Option 4: Manual Query Execution
Copy and paste the contents of `neo4j/init.cypher` directly into Neo4j Browser and run it.