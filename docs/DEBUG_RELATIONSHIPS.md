# 🔍 Debug Relationships - Run These to See What's Missing

## 1. Check All Relationships
```cypher
MATCH ()-[r]->() 
RETURN type(r) as RelationType, count(r) as Count 
ORDER BY Count DESC
```

## 2. See All Actual Relationships (Sample)
```cypher
MATCH (a)-[r]->(b)
RETURN 
  labels(a)[0] + ':' + coalesce(a.name, a.id) as From, 
  type(r) as Relationship, 
  labels(b)[0] + ':' + coalesce(b.name, b.id) as To
LIMIT 20
```

## 3. Check Specific User Relationships
```cypher
MATCH (u:User {name: 'Sarah Chen'})-[r]->(n)
RETURN u.name, type(r), labels(n), n.name
```

## 4. Check Service Nodes
```cypher
MATCH (s:Service)
RETURN s.name, s.type, s.contains_pii, labels(s)
```

## 5. Check Role Nodes
```cypher
MATCH (r:Role)
RETURN r.name, r.type, labels(r)
```

**Run these first to see what's actually in the database!**