# ✅ Working Dashboard Queries - Fixed Versions

These queries should now work with the fixed relationships:

## 1. AWS Privilege Escalation (Fixed)
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

## 2. Cross-Cloud Attack Chain (Fixed)
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

## 3. Kubernetes RBAC Escalation (Fixed)
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
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as EscalationPath,
    CASE 
        WHEN role.name CONTAINS 'admin' OR role.name = 'cluster-admin' THEN 'HIGH RISK'
        WHEN role.rules CONTAINS '*' THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END as RiskLevel
ORDER BY RiskLevel DESC, EscalationSteps
LIMIT 10
```

## 4. Supply Chain Container Escape (Fixed)
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

## 5. Simple Relationship Verification
```cypher
// Check all relationship types
MATCH ()-[r]->() 
RETURN type(r) as RelationType, count(r) as Count 
ORDER BY Count DESC
```

## 6. Show All Attack Paths
```cypher
// Show all user attack paths
MATCH path = (u:User)-[*1..3]->(target)
WHERE u.access_level IS NOT NULL
RETURN 
    u.name as User,
    u.access_level as Level,
    labels(target)[0] as TargetType,
    coalesce(target.name, target.id) as Target,
    length(path) as Steps,
    [rel in relationships(path) | type(rel)] as Path
ORDER BY Steps, User
LIMIT 15
```

**All of these should now return results!** 🎯