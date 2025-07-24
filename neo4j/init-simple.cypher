// Cloud Threat Graph Lab - Phase 1 Simple Data Load
// Simplified version to ensure data loads correctly

// Clear existing data
MATCH (n) DETACH DELETE n;

// ==============================================
// Create Basic AWS Scenario
// ==============================================

// Create AWS User
CREATE (dev_user:User:AWSUser {
  id: 'aws-user-dev-001',
  name: 'Sarah Chen',
  email: 'sarah.chen@company.com',
  access_level: 'developer',
  account_id: '123456789012'
});

// Create AWS Role
CREATE (admin_role:Role:AWSRole {
  id: 'aws-role-admin-001',
  name: 'AdminRole',
  arn: 'arn:aws:iam::123456789012:role/AdminRole',
  account_id: '123456789012',
  permissions: ['iam:*', 's3:*', 'ec2:*']
});

// Create AWS Service
CREATE (s3_bucket:Service:AWSService {
  id: 'aws-s3-sensitive-001',
  name: 'company-sensitive-data',
  type: 'S3Bucket',
  region: 'us-east-1',
  contains_pii: true
});

// Create relationships
CREATE (dev_user)-[:ASSUMES_ROLE {method: 'sts:AssumeRole'}]->(admin_role);
CREATE (admin_role)-[:CAN_ACCESS {permissions: ['s3:GetObject']}]->(s3_bucket);
CREATE (dev_user)-[:CAN_ACCESS {method: 'Through roles'}]->(s3_bucket);

// ==============================================
// Create Basic Azure→AWS Scenario  
// ==============================================

// Create Azure User
CREATE (azure_dev:User:AzureUser {
  id: 'azure-user-dev-001',
  name: 'Emma Watson',
  email: 'emma.watson@company.com',
  tenant_id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
});

// Create CI/CD Service
CREATE (github_actions:Service:CICDService {
  id: 'github-actions-001',
  name: 'Deploy Pipeline',
  platform: 'GitHub Actions',
  repository: 'company/infrastructure'
});

// Create Cross-Cloud Role
CREATE (cross_cloud_role:Role:AWSRole {
  id: 'aws-role-cicd-001',
  name: 'GitHubActionsRole',
  arn: 'arn:aws:iam::123456789012:role/GitHubActionsRole',
  account_id: '123456789012'
});

// Create relationships
CREATE (azure_dev)-[:HAS_ACCESS_TO {permissions: ['push']}]->(github_actions);
CREATE (github_actions)-[:ASSUMES_ROLE {method: 'OIDC federation'}]->(cross_cloud_role);
CREATE (cross_cloud_role)-[:CAN_ACCESS {permissions: ['s3:PutObject']}]->(s3_bucket);
CREATE (azure_dev)-[:CAN_ACCESS {method: 'Through CI/CD'}]->(s3_bucket);

// ==============================================
// Create Basic K8s Scenario
// ==============================================

// Create Pod
CREATE (web_pod:Pod:K8sResource {
  id: 'k8s-pod-webapp-001',
  name: 'webapp-deployment-7d4b8c9f5-x7k2m',
  namespace: 'production',
  image: 'nginx:1.21'
});

// Create Service Account
CREATE (app_sa:ServiceAccount:K8sResource {
  id: 'k8s-sa-app-001',
  name: 'webapp-service-account',
  namespace: 'production'
});

// Create Role
CREATE (pod_reader:Role:K8sRole {
  id: 'k8s-role-pod-reader',
  name: 'pod-reader',
  type: 'Role',
  namespace: 'production',
  rules: ['pods.get', 'pods.list']
});

// Create RoleBinding
CREATE (sa_binding:RoleBinding:K8sResource {
  id: 'k8s-rb-webapp-001',
  name: 'webapp-binding',
  namespace: 'production',
  type: 'RoleBinding'
});

// Create relationships
CREATE (web_pod)-[:MOUNTS_SA {token_path: '/var/run/secrets/kubernetes.io/serviceaccount/token'}]->(app_sa);
CREATE (app_sa)-[:BOUND_TO {binding_name: 'webapp-binding'}]->(sa_binding);
CREATE (sa_binding)-[:GRANTS_ROLE {scope: 'namespace'}]->(pod_reader);

// ==============================================
// Create Basic Supply Chain Scenario
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

// Create Image
CREATE (docker_image:Image:ContainerResource {
  id: 'docker-image-001',
  name: 'company/webapp',
  tag: 'v1.2.3',
  base_image: 'node:18-alpine',
  contains_secrets: true
});

// Create Host
CREATE (host_system:Host:InfrastructureResource {
  id: 'host-system-001',
  name: 'prod-worker-01',
  os: 'Ubuntu 20.04',
  container_runtime: 'containerd'
});

// Create relationships
CREATE (npm_package)-[:EMBEDDED_IN {build_stage: 'npm install'}]->(docker_image);
CREATE (docker_image)-[:DEPLOYED_TO {pull_policy: 'Always'}]->(web_pod);
CREATE (web_pod)-[:RUNS_ON {container_runtime: 'containerd'}]->(host_system);
CREATE (docker_image)-[:CAN_ESCAPE_TO {method: 'Privileged container'}]->(host_system);

// Final verification
MATCH (n) RETURN count(n) as TotalNodesCreated;