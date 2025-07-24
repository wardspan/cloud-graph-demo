// Complete relationship fix for all scenarios

// Add K8s relationships
MATCH (pod:Pod {name: 'webapp-deployment-7d4b8c9f5-x7k2m'})
MATCH (sa:ServiceAccount {name: 'webapp-service-account'})
MERGE (pod)-[:MOUNTS_SA {token_path: '/var/run/secrets/kubernetes.io/serviceaccount/token'}]->(sa);

MATCH (sa:ServiceAccount {name: 'webapp-service-account'})
MATCH (binding:RoleBinding {name: 'webapp-binding'})
MERGE (sa)-[:BOUND_TO {binding_name: 'webapp-binding'}]->(binding);

MATCH (binding:RoleBinding {name: 'webapp-binding'})
MATCH (role:Role {name: 'pod-reader'})
MERGE (binding)-[:GRANTS_ROLE {scope: 'namespace'}]->(role);

// Add supply chain relationships
MATCH (pkg:Package {name: 'popular-utility-lib'})
MATCH (img:Image {name: 'company/webapp'})
MERGE (pkg)-[:EMBEDDED_IN {build_stage: 'npm install'}]->(img);

MATCH (img:Image {name: 'company/webapp'})
MATCH (pod:Pod {name: 'webapp-deployment-7d4b8c9f5-x7k2m'})
MERGE (img)-[:DEPLOYED_TO {pull_policy: 'Always'}]->(pod);

MATCH (pod:Pod {name: 'webapp-deployment-7d4b8c9f5-x7k2m'})
MATCH (host:Host {name: 'prod-worker-01'})
MERGE (pod)-[:RUNS_ON {container_runtime: 'containerd'}]->(host);

MATCH (img:Image {name: 'company/webapp'})
MATCH (host:Host {name: 'prod-worker-01'})
MERGE (img)-[:CAN_ESCAPE_TO {method: 'Privileged container'}]->(host);

// Verify all relationships were created
MATCH ()-[r]->() 
RETURN type(r) as RelationType, count(r) as Count 
ORDER BY Count DESC;