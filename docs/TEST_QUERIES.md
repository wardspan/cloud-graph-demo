# ✅ Test These Queries After Fresh Boot

Run these in Neo4j Browser (http://localhost:7474) with neo4j/cloudsecurity:

## 1. Verify Data Loaded
```cypher
MATCH (n) RETURN labels(n)[0] as NodeType, count(n) as Count ORDER BY Count DESC
```
**Expected:** Should show Users, Services, Roles, Pods, etc.

## 2. Test Direct User→Service Access (This Should Work Now!)
```cypher
MATCH (u:User)-[r:CAN_ACCESS]->(s:Service)
RETURN u.name as User, s.name as Service, r.method as AccessMethod
ORDER BY User
```
**Expected:** Should show Sarah Chen and Emma Watson accessing services

## 3. Test Attack Paths (Dashboard Query)
```cypher
MATCH path = (u:User)-[*1..3]->(s:Service)
WHERE u.access_level = 'developer' 
  AND (s.contains_pii = true OR s.type = 'S3Bucket')
RETURN 
    u.name as StartUser,
    u.email as Email,
    u.access_level as StartLevel,
    s.name as TargetService,
    s.type as ServiceType,
    s.contains_pii as ContainsPII,
    length(path) as EscalationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as AttackPath,
    [rel in relationships(path) | type(rel)] as Relations
ORDER BY EscalationSteps
LIMIT 10
```
**Expected:** Should show attack paths from Sarah Chen to S3 bucket

## 4. Test K8s RBAC Query
```cypher
MATCH path = (pod:Pod)-[*1..3]->(role:Role)
WHERE pod.namespace IS NOT NULL
RETURN 
    pod.name as Pod,
    pod.namespace as PodNamespace,
    role.name as GrantedRole,
    role.type as RoleType,
    role.rules as Permissions,
    length(path) as EscalationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as EscalationPath
ORDER BY EscalationSteps
LIMIT 10
```
**Expected:** Should show K8s pod escalation paths

## 5. Test Cross-Cloud Query
```cypher
MATCH path = (azure:User)-[*1..4]->(aws:Service)
WHERE azure.tenant_id IS NOT NULL 
  AND (aws.type = 'S3Bucket' OR labels(aws) CONTAINS 'AWSService')
RETURN 
    azure.name as AzureUser,
    azure.email as Email,
    azure.tenant_id as TenantID,
    aws.name as AWSTarget,
    aws.type as ServiceType,
    length(path) as PathLength,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as AttackChain,
    [rel in relationships(path) | type(rel)] as AttackMethods
ORDER BY PathLength
LIMIT 10
```
**Expected:** Should show Emma Watson's cross-cloud attack paths

## 6. Test Supply Chain Query
```cypher
MATCH path = (pkg:Package)-[*1..4]->(host:Host)
WHERE pkg.compromised = true
RETURN 
    pkg.name as CompromisedPackage,
    pkg.version as Version,
    pkg.payload_type as PayloadType,
    pkg.registry as Registry,
    host.name as CompromisedHost,
    host.os as HostOS,
    host.container_runtime as Runtime,
    length(path) as EscalationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as FullAttackChain,
    [rel in relationships(path) | type(rel)] as AttackMethods
ORDER BY EscalationSteps
LIMIT 10
```
**Expected:** Should show supply chain attack from npm package to host

**ALL of these queries should now return results!** 🎯