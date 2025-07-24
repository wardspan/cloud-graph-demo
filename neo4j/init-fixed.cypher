// Cloud Threat Graph Lab - Fixed Version with Proper Relationships
// This version uses MATCH instead of variables to ensure relationships work

// Clear existing data
MATCH (n) DETACH DELETE n;

// ==============================================
// CREATE ALL NODES FIRST
// ==============================================

// AWS Users
CREATE (:User:AWSUser {
  id: 'aws-user-dev-001',
  name: 'Sarah Chen',
  email: 'sarah.chen@company.com',
  access_level: 'developer',
  account_id: '123456789012'
});

CREATE (:User:AzureUser {
  id: 'azure-user-dev-001',
  name: 'Emma Watson',
  email: 'emma.watson@company.com',
  tenant_id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  access_level: 'developer'
});

// AWS Roles
CREATE (:Role:AWSRole {
  id: 'aws-role-admin-001',
  name: 'AdminRole',
  arn: 'arn:aws:iam::123456789012:role/AdminRole',
  account_id: '123456789012',
  permissions: ['iam:*', 's3:*', 'ec2:*']
});

CREATE (:Role:AWSRole {
  id: 'aws-role-cicd-001',
  name: 'GitHubActionsRole',
  arn: 'arn:aws:iam::123456789012:role/GitHubActionsRole',
  account_id: '123456789012',
  permissions: ['s3:PutObject', 's3:GetObject']
});

// AWS Services
CREATE (:Service:AWSService {
  id: 'aws-s3-sensitive-001',
  name: 'company-sensitive-data',
  type: 'S3Bucket',
  region: 'us-east-1',
  contains_pii: true
});

CREATE (:Service:AWSService {
  id: 'aws-lambda-processor-001',
  name: 'data-processor-function',
  type: 'LambdaFunction',
  runtime: 'python3.9', 
  region: 'us-east-1',
  contains_pii: false
});

// CI/CD Service
CREATE (:Service:CICDService {
  id: 'github-actions-001',
  name: 'Deploy Pipeline',
  platform: 'GitHub Actions',
  repository: 'company/infrastructure'
});

// K8s Resources
CREATE (:Pod:K8sResource {
  id: 'k8s-pod-webapp-001',
  name: 'webapp-deployment-7d4b8c9f5-x7k2m',
  namespace: 'production',
  image: 'nginx:1.21'
});

CREATE (:ServiceAccount:K8sResource {
  id: 'k8s-sa-app-001',
  name: 'webapp-service-account',
  namespace: 'production'
});

CREATE (:Role:K8sRole {
  id: 'k8s-role-pod-reader',
  name: 'pod-reader',
  type: 'Role',
  namespace: 'production',
  rules: ['pods.get', 'pods.list']
});

CREATE (:RoleBinding:K8sResource {
  id: 'k8s-rb-webapp-001',
  name: 'webapp-binding',
  namespace: 'production',
  type: 'RoleBinding'
});

// Supply Chain
CREATE (:Package:SupplyChain {
  id: 'npm-package-compromise-001',
  name: 'popular-utility-lib',
  version: '2.1.4',
  registry: 'npmjs.org',
  compromised: true,
  payload_type: 'backdoor'
});

CREATE (:Image:ContainerResource {
  id: 'docker-image-001',
  name: 'company/webapp',
  tag: 'v1.2.3',
  base_image: 'node:18-alpine',
  contains_secrets: true
});

CREATE (:Host:InfrastructureResource {
  id: 'host-system-001',
  name: 'prod-worker-01',
  os: 'Ubuntu 20.04',
  container_runtime: 'containerd'
});

// Wait a moment for nodes to be created
WITH count(*) as nodeCount
WHERE nodeCount > 0

// ==============================================
// CREATE RELATIONSHIPS USING MATCH
// ==============================================

// AWS Privilege Escalation - Direct User to Service Access
MATCH (sarah:User {name: 'Sarah Chen'})
MATCH (s3:Service {name: 'company-sensitive-data'})
CREATE (sarah)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Developer access via role escalation'
}]->(s3)

WITH *
MATCH (sarah:User {name: 'Sarah Chen'})
MATCH (lambda:Service {name: 'data-processor-function'})
CREATE (sarah)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Developer access via role escalation'
}]->(lambda)

// Role-based relationships
WITH *
MATCH (sarah:User {name: 'Sarah Chen'})
MATCH (admin_role:Role {name: 'AdminRole'})
CREATE (sarah)-[:ASSUMES_ROLE {
  method: 'sts:AssumeRole'
}]->(admin_role)

WITH *
MATCH (admin_role:Role {name: 'AdminRole'})
MATCH (s3:Service {name: 'company-sensitive-data'})
CREATE (admin_role)-[:CAN_ACCESS {
  permissions: ['s3:GetObject', 's3:ListBucket']
}]->(s3)

// Cross-Cloud Attack - Azure to AWS
WITH *
MATCH (emma:User {name: 'Emma Watson'})
MATCH (s3:Service {name: 'company-sensitive-data'})
CREATE (emma)-[:CAN_ACCESS {
  method: 'Through CI/CD pipeline',
  description: 'Cross-cloud access via GitHub Actions'
}]->(s3)

WITH *
MATCH (emma:User {name: 'Emma Watson'})
MATCH (github:Service {name: 'Deploy Pipeline'})
CREATE (emma)-[:HAS_ACCESS_TO {
  permissions: ['push', 'workflow_dispatch']
}]->(github)

WITH *
MATCH (github:Service {name: 'Deploy Pipeline'})
MATCH (cicd_role:Role {name: 'GitHubActionsRole'})
CREATE (github)-[:ASSUMES_ROLE {
  method: 'OIDC federation'
}]->(cicd_role)

WITH *
MATCH (cicd_role:Role {name: 'GitHubActionsRole'})
MATCH (s3:Service {name: 'company-sensitive-data'})
CREATE (cicd_role)-[:CAN_ACCESS {
  permissions: ['s3:PutObject', 's3:GetObject']
}]->(s3)

// K8s RBAC relationships
WITH *
MATCH (pod:Pod {name: 'webapp-deployment-7d4b8c9f5-x7k2m'})
MATCH (sa:ServiceAccount {name: 'webapp-service-account'})
CREATE (pod)-[:MOUNTS_SA {
  token_path: '/var/run/secrets/kubernetes.io/serviceaccount/token'
}]->(sa)

WITH *
MATCH (sa:ServiceAccount {name: 'webapp-service-account'})
MATCH (binding:RoleBinding {name: 'webapp-binding'})
CREATE (sa)-[:BOUND_TO {
  binding_name: 'webapp-binding'
}]->(binding)

WITH *
MATCH (binding:RoleBinding {name: 'webapp-binding'})
MATCH (role:Role {name: 'pod-reader'})
CREATE (binding)-[:GRANTS_ROLE {
  scope: 'namespace'
}]->(role)

// Supply Chain relationships
WITH *
MATCH (pkg:Package {name: 'popular-utility-lib'})
MATCH (img:Image {name: 'company/webapp'})
CREATE (pkg)-[:EMBEDDED_IN {
  build_stage: 'npm install'
}]->(img)

WITH *
MATCH (img:Image {name: 'company/webapp'})
MATCH (pod:Pod {name: 'webapp-deployment-7d4b8c9f5-x7k2m'})
CREATE (img)-[:DEPLOYED_TO {
  pull_policy: 'Always'
}]->(pod)

WITH *
MATCH (pod:Pod {name: 'webapp-deployment-7d4b8c9f5-x7k2m'})
MATCH (host:Host {name: 'prod-worker-01'})
CREATE (pod)-[:RUNS_ON {
  container_runtime: 'containerd'
}]->(host)

WITH *
MATCH (img:Image {name: 'company/webapp'})
MATCH (host:Host {name: 'prod-worker-01'})
CREATE (img)-[:CAN_ESCAPE_TO {
  method: 'Privileged container'
}]->(host)

// Final verification
WITH *
MATCH (n)
WITH count(n) as total_nodes
MATCH ()-[r]->()
WITH total_nodes, count(r) as total_relationships
MATCH (u:User)-[:CAN_ACCESS]->(s:Service)
WITH total_nodes, total_relationships, count(*) as working_paths

RETURN 
  total_nodes as TotalNodes,
  total_relationships as TotalRelationships,
  working_paths as WorkingAttackPaths,
  "Data loaded with working relationships!" as Status;