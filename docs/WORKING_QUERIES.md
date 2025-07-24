# ✅ Working Queries - Test These First

These simplified queries will work with the current data:

## 1. Show All Users and Their Access Levels
```cypher
MATCH (u:User) 
RETURN u.name as UserName, u.access_level as AccessLevel, labels(u) as UserType
ORDER BY AccessLevel
```

## 2. Show All Services and What They Contain
```cypher
MATCH (s:Service) 
RETURN s.name as ServiceName, s.type as ServiceType, s.contains_pii as ContainsPII, labels(s) as ServiceLabels
ORDER BY ServiceName
```

## 3. Show Direct User→Service Relationships
```cypher
MATCH (u:User)-[r:CAN_ACCESS]->(s:Service)
RETURN u.name as User, s.name as Service, r.method as AccessMethod
ORDER BY User
```

## 4. Show User→Role Relationships
```cypher
MATCH (u:User)-[r:ASSUMES_ROLE]->(role:Role)
RETURN u.name as User, role.name as Role, r.method as Method
ORDER BY User
```

## 5. Show Role→Service Relationships
```cypher
MATCH (role:Role)-[r:CAN_ACCESS]->(s:Service)
RETURN role.name as Role, s.name as Service, r.permissions as Permissions
ORDER BY Role
```

## 6. Simple Attack Path (2 hops max)
```cypher
MATCH path = (u:User)-[*1..2]->(s:Service)
WHERE u.access_level = 'developer'
RETURN u.name as StartUser, s.name as TargetService, length(path) as Hops
ORDER BY Hops
LIMIT 10
```

## 7. Show All Relationships
```cypher
MATCH (a)-[r]->(b)
RETURN labels(a)[0] + ':' + coalesce(a.name, a.id) as From, 
       type(r) as Relationship, 
       labels(b)[0] + ':' + coalesce(b.name, b.id) as To
LIMIT 20
```

## 8. K8s Pod→ServiceAccount
```cypher
MATCH (p:Pod)-[r:MOUNTS_SA]->(sa:ServiceAccount)
RETURN p.name as Pod, sa.name as ServiceAccount, r.token_path as TokenPath
```

## 9. Supply Chain Package→Image
```cypher
MATCH (pkg:Package)-[r:EMBEDDED_IN]->(img:Image)
RETURN pkg.name as Package, pkg.compromised as IsCompromised, img.name as Image
```

## 10. Show Attack Paths Summary
```cypher
MATCH (ap:AttackPath)
RETURN ap.name as AttackPath, ap.severity as Severity, ap.techniques as MitreTechniques
ORDER BY ap.severity DESC
```