// Cloud Threat Graph Lab - Complete Working Data Load
// This script creates all nodes and relationships needed for the dashboard queries

// Clear existing data
MATCH (n) DETACH DELETE n;

// ==============================================
// SCENARIO 1: AWS Privilege Escalation
// ==============================================

// Create AWS Users
CREATE (dev_user:User:AWSUser {
  id: 'aws-user-dev-001',
  name: 'Sarah Chen',
  email: 'sarah.chen@company.com',
  access_level: 'developer',
  account_id: '123456789012',
  type: 'IAMUser'
});

CREATE (admin_user:User:AWSUser {
  id: 'aws-user-admin-001', 
  name: 'Mike Rodriguez',
  email: 'mike.rodriguez@company.com',
  access_level: 'administrator',
  account_id: '123456789012',
  type: 'IAMUser'
});

// Create AWS Roles
CREATE (dev_role:Role:AWSRole {
  id: 'aws-role-dev-001',
  name: 'DeveloperRole',
  arn: 'arn:aws:iam::123456789012:role/DeveloperRole',
  account_id: '123456789012',
  type: 'IAMRole',
  permissions: ['s3:GetObject', 'lambda:InvokeFunction']
});

CREATE (admin_role:Role:AWSRole {
  id: 'aws-role-admin-001',
  name: 'AdminRole', 
  arn: 'arn:aws:iam::123456789012:role/AdminRole',
  account_id: '123456789012',
  type: 'IAMRole',
  permissions: ['iam:*', 's3:*', 'ec2:*']
});

// Create AWS Services
CREATE (s3_bucket:Service:AWSService {
  id: 'aws-s3-sensitive-001',
  name: 'company-sensitive-data',
  type: 'S3Bucket',
  region: 'us-east-1',
  contains_pii: true,
  encryption: 'AES256'
});

CREATE (lambda_func:Service:AWSService {
  id: 'aws-lambda-processor-001',
  name: 'data-processor-function', 
  type: 'LambdaFunction',
  runtime: 'python3.9',
  region: 'us-east-1',
  contains_pii: false
});

// Create AWS relationships - Complete attack path
CREATE (dev_user)-[:ASSUMES_ROLE {
  method: 'sts:AssumeRole',
  conditions: 'MFA not required'
}]->(dev_role);

CREATE (dev_role)-[:CAN_ESCALATE_TO {
  method: 'iam:PassRole misconfiguration',
  vulnerability: 'Overly permissive trust policy'
}]->(admin_role);

CREATE (admin_role)-[:CAN_ACCESS {
  permissions: ['s3:GetObject', 's3:ListBucket'],
  access_type: 'full'
}]->(s3_bucket);

CREATE (admin_role)-[:CAN_ACCESS {
  permissions: ['lambda:InvokeFunction', 'lambda:GetFunction'],
  access_type: 'execute'
}]->(lambda_func);

// Direct access paths for queries
CREATE (dev_user)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Via role escalation chain'
}]->(s3_bucket);

CREATE (dev_user)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Via role escalation chain'
}]->(lambda_func);

// ==============================================
// SCENARIO 2: Cross-Cloud Attack (Azure → AWS)
// ==============================================

// Create Azure User
CREATE (azure_dev:User:AzureUser {
  id: 'azure-user-dev-001',
  name: 'Emma Watson',
  email: 'emma.watson@company.com',
  tenant_id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  upn: 'emma.watson@company.onmicrosoft.com',
  access_level: 'developer'
});

// Create CI/CD Service
CREATE (github_actions:Service:CICDService {
  id: 'github-actions-001',
  name: 'Deploy Pipeline',
  platform: 'GitHub Actions',
  repository: 'company/infrastructure',
  type: 'CICDPipeline'
});

// Create Cross-Cloud Role
CREATE (cross_cloud_role:Role:AWSRole {
  id: 'aws-role-cicd-001',
  name: 'GitHubActionsRole',
  arn: 'arn:aws:iam::123456789012:role/GitHubActionsRole',
  account_id: '123456789012',
  type: 'IAMRole',
  permissions: ['s3:PutObject', 's3:GetObject']
});

// Cross-cloud relationships
CREATE (azure_dev)-[:HAS_ACCESS_TO {
  permissions: ['push', 'workflow_dispatch'],
  access_level: 'write'
}]->(github_actions);

CREATE (github_actions)-[:ASSUMES_ROLE {
  method: 'OIDC federation',
  token_source: 'GitHub OIDC provider'
}]->(cross_cloud_role);

CREATE (cross_cloud_role)-[:CAN_ACCESS {
  permissions: ['s3:PutObject', 's3:GetObject'],
  deployment_target: true
}]->(s3_bucket);

// Direct access for queries
CREATE (azure_dev)-[:CAN_ACCESS {
  method: 'Through CI/CD pipeline',
  description: 'Cross-cloud access via GitHub Actions'
}]->(s3_bucket);

// ==============================================
// SCENARIO 3: Kubernetes RBAC Escalation
// ==============================================

// Create Namespaces
CREATE (prod_namespace:Namespace:K8sResource {
  id: 'k8s-ns-production',
  name: 'production',
  cluster: 'prod-cluster-us-east'
});

CREATE (default_namespace:Namespace:K8sResource {
  id: 'k8s-ns-default', 
  name: 'default',
  cluster: 'prod-cluster-us-east'
});

// Create Service Accounts
CREATE (app_sa:ServiceAccount:K8sResource {
  id: 'k8s-sa-app-001',
  name: 'webapp-service-account',
  namespace: 'production',
  automount_token: true
});

CREATE (admin_sa:ServiceAccount:K8sResource {
  id: 'k8s-sa-admin-001',
  name: 'cluster-admin-sa',
  namespace: 'kube-system',
  automount_token: true
});

// Create Roles
CREATE (pod_reader:Role:K8sRole {
  id: 'k8s-role-pod-reader',
  name: 'pod-reader',
  type: 'Role',
  namespace: 'production',
  rules: ['pods.get', 'pods.list']
});

CREATE (cluster_admin:Role:K8sRole {
  id: 'k8s-role-cluster-admin',
  name: 'cluster-admin',
  type: 'ClusterRole',
  rules: ['*.*.*'],
  builtin: true
});

// Create RoleBindings
CREATE (sa_binding:RoleBinding:K8sResource {
  id: 'k8s-rb-webapp-001',
  name: 'webapp-binding',
  namespace: 'production',
  type: 'RoleBinding'
});

CREATE (cluster_binding:RoleBinding:K8sResource {
  id: 'k8s-crb-admin-001',
  name: 'admin-cluster-binding', 
  type: 'ClusterRoleBinding'
});

// Create Pods
CREATE (web_pod:Pod:K8sResource {
  id: 'k8s-pod-webapp-001',
  name: 'webapp-deployment-7d4b8c9f5-x7k2m',
  namespace: 'production',
  image: 'nginx:1.21',
  service_account: 'webapp-service-account'
});

CREATE (admin_pod:Pod:K8sResource {
  id: 'k8s-pod-admin-001',
  name: 'admin-pod-xyz123',
  namespace: 'kube-system',
  image: 'kubectl:latest',
  service_account: 'cluster-admin-sa'
});

// K8s relationships
CREATE (web_pod)-[:MOUNTS_SA {
  token_path: '/var/run/secrets/kubernetes.io/serviceaccount/token',
  auto_mount: true
}]->(app_sa);

CREATE (admin_pod)-[:MOUNTS_SA {
  token_path: '/var/run/secrets/kubernetes.io/serviceaccount/token',
  auto_mount: true
}]->(admin_sa);

CREATE (app_sa)-[:BOUND_TO {
  binding_name: 'webapp-binding'
}]->(sa_binding);

CREATE (admin_sa)-[:BOUND_TO {
  binding_name: 'admin-cluster-binding'
}]->(cluster_binding);

CREATE (sa_binding)-[:GRANTS_ROLE {
  scope: 'namespace',
  namespace: 'production'
}]->(pod_reader);

CREATE (cluster_binding)-[:GRANTS_ROLE {
  scope: 'cluster',
  permissions: 'all'
}]->(cluster_admin);

// Escalation path
CREATE (app_sa)-[:CAN_ESCALATE_TO {
  method: 'ServiceAccount token reuse',
  vulnerability: 'Overprivileged service account'
}]->(admin_sa);

// ==============================================
// SCENARIO 4: Supply Chain & Container Escape
// ==============================================

// Create Package
CREATE (npm_package:Package:SupplyChain {
  id: 'npm-package-compromise-001',
  name: 'popular-utility-lib',
  version: '2.1.4',
  registry: 'npmjs.org',
  compromised: true,
  payload_type: 'backdoor'
});

// Create Container Image
CREATE (docker_image:Image:ContainerResource {
  id: 'docker-image-001',
  name: 'company/webapp',
  tag: 'v1.2.3',
  base_image: 'node:18-alpine',
  contains_secrets: true,
  privileged_capabilities: ['SYS_ADMIN']
});

// Create Host
CREATE (host_system:Host:InfrastructureResource {
  id: 'host-system-001',
  name: 'prod-worker-01',
  os: 'Ubuntu 20.04',
  container_runtime: 'containerd',
  kernel_version: '5.4.0-74-generic'
});

// Supply chain relationships
CREATE (npm_package)-[:EMBEDDED_IN {
  build_stage: 'npm install',
  detection_bypassed: true
}]->(docker_image);

CREATE (docker_image)-[:DEPLOYED_TO {
  pull_policy: 'Always',
  vulnerability_scan: false
}]->(web_pod);

CREATE (web_pod)-[:RUNS_ON {
  container_runtime: 'containerd',
  security_context: 'privileged'
}]->(host_system);

CREATE (docker_image)-[:CAN_ESCAPE_TO {
  method: 'Privileged container + kernel exploit',
  cve: 'CVE-2022-0847'
}]->(host_system);

// ==============================================
// ATTACK PATH METADATA
// ==============================================

CREATE (attack_path_1:AttackPath {
  id: 'path-aws-privilege-escalation',
  name: 'AWS IAM Privilege Escalation',
  description: 'Developer user escalates to admin via role assumption',
  techniques: ['T1078.004', 'T1548.005', 'T1134.001'],
  severity: 'HIGH',
  steps: 3
});

CREATE (attack_path_2:AttackPath {
  id: 'path-cross-cloud',
  name: 'Cross-Cloud Attack Chain',
  description: 'Azure AD user compromises AWS resources via CI/CD',
  techniques: ['T1078.004', 'T1195.002', 'T1552.004'],
  severity: 'CRITICAL',
  steps: 4
});

CREATE (attack_path_3:AttackPath {
  id: 'path-k8s-rbac',
  name: 'Kubernetes RBAC Escalation',
  description: 'Pod service account escalates to cluster admin',
  techniques: ['T1134.001', 'T1548.005', 'T1613'],
  severity: 'HIGH',
  steps: 3
});

CREATE (attack_path_4:AttackPath {
  id: 'path-supply-chain',
  name: 'Supply Chain Container Escape',
  description: 'Compromised package leads to host compromise',
  techniques: ['T1195.002', 'T1610', 'T1611'],
  severity: 'CRITICAL',
  steps: 4
});

// ==============================================
// VERIFICATION QUERIES
// ==============================================

// Count all nodes
MATCH (n) 
WITH count(n) as total_nodes

// Count relationships  
MATCH ()-[r]->()
WITH total_nodes, count(r) as total_relationships

// Count users with attack paths
MATCH (u:User)-[:CAN_ACCESS]->(s:Service)
WITH total_nodes, total_relationships, count(DISTINCT u) as users_with_access

// Final verification
RETURN 
  total_nodes as TotalNodes,
  total_relationships as TotalRelationships, 
  users_with_access as UsersWithDirectAccess,
  "Cloud Threat Graph Lab data loaded successfully!" as Status;