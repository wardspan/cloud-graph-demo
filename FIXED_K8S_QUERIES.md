# 🔧 Fixed Kubernetes RBAC Queries

## Query 1: Complete RBAC Escalation Paths
```cypher
// Analyze complete RBAC escalation paths
MATCH rbacPath = (pod:Pod)-[:MOUNTS_SA]->(sa:ServiceAccount)-[:BOUND_TO]->(binding:RoleBinding)-[:GRANTS_ROLE]->(role:Role) 
RETURN 
    pod.name as Pod, 
    pod.namespace as PodNamespace, 
    pod.service_account as MountedSA, 
    sa.name as ServiceAccount, 
    sa.namespace as SANamespace, 
    binding.name as RoleBinding, 
    binding.type as BindingType, 
    role.name as GrantedRole, 
    role.type as RoleType, 
    role.rules as Permissions, 
    CASE 
        WHEN role.name CONTAINS 'admin' OR role.name = 'cluster-admin' THEN 'HIGH RISK'
        WHEN role.rules CONTAINS '*' THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END as RiskLevel
ORDER BY RiskLevel DESC, PodNamespace, Pod
```

## Query 2: Potential Escalation Paths
```cypher
// Show potential escalation paths
MATCH escalationPath = (sa1:ServiceAccount)-[:CAN_ESCALATE_TO]->(sa2:ServiceAccount) 
OPTIONAL MATCH (pod:Pod)-[:MOUNTS_SA]->(sa1) 
RETURN 
    pod.name as Pod, 
    pod.namespace as PodNamespace, 
    sa1.name as ServiceAccount, 
    sa1.namespace as SANamespace, 
    'ESCALATION_TARGET' as RoleBinding, 
    'Privilege Escalation' as BindingType, 
    sa2.name as GrantedRole, 
    'ServiceAccount' as RoleType, 
    'ESCALATED_PRIVILEGES' as Permissions, 
    'CRITICAL RISK' as RiskLevel
ORDER BY RiskLevel DESC
```

## Query 3: Simple K8s Path Analysis (Recommended)
```cypher  
// Simplified K8s RBAC analysis that should work
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

## Query 4: Check What K8s Relationships Exist
```cypher
// First check what K8s relationships we actually have
MATCH (pod:Pod)-[r]->(target)
RETURN pod.name, type(r), labels(target), coalesce(target.name, target.id)
UNION
MATCH (sa:ServiceAccount)-[r]->(target) 
RETURN sa.name, type(r), labels(target), coalesce(target.name, target.id)
UNION  
MATCH (binding:RoleBinding)-[r]->(target)
RETURN binding.name, type(r), labels(target), coalesce(target.name, target.id)
```

**Use Query 3 (Simple K8s Path Analysis) - it should work with our current data!**