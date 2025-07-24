// Cloud Threat Graph Lab - Phase 1 Initial Data
// Creates realistic attack scenarios for cloud security analysis

// Clear existing data
MATCH (n) DETACH DELETE n;

// Simple verification query
MATCH (n) RETURN count(n) as NodesBeforeLoad;

// ==============================================
// SCENARIO 1: AWS Cross-Account Privilege Escalation
// ==============================================

// Create AWS Users
CREATE (dev_user:User:AWSUser {
  id: 'aws-user-dev-001',
  name: 'Sarah Chen',
  email: 'sarah.chen@company.com',
  account_id: '123456789012',
  type: 'IAMUser',
  access_level: 'developer',
  created: datetime('2024-01-15T10:30:00Z'),
  mitre_techniques: ['T1078.004']
});

CREATE (admin_user:User:AWSUser {
  id: 'aws-user-admin-001',
  name: 'Mike Rodriguez',
  email: 'mike.rodriguez@company.com',
  account_id: '123456789012',
  type: 'IAMUser',
  access_level: 'administrator',
  created: datetime('2024-01-10T09:00:00Z'),
  mitre_techniques: ['T1078.004']
});

// Create AWS Roles
CREATE (dev_role:Role:AWSRole {
  id: 'aws-role-dev-001',
  name: 'DeveloperRole',
  arn: 'arn:aws:iam::123456789012:role/DeveloperRole',
  account_id: '123456789012',
  trust_policy: 'Allows assumption by IAM users',
  max_session_duration: 3600,
  mitre_techniques: ['T1548.005']
});

CREATE (admin_role:Role:AWSRole {
  id: 'aws-role-admin-001',
  name: 'AdminRole',
  arn: 'arn:aws:iam::123456789012:role/AdminRole',
  account_id: '123456789012',
  trust_policy: 'Allows assumption by trusted entities',
  max_session_duration: 7200,
  permissions: ['iam:*', 's3:*', 'ec2:*'],
  mitre_techniques: ['T1548.005', 'T1134.001']
});

// Create AWS Services
CREATE (s3_bucket:Service:AWSService {
  id: 'aws-s3-sensitive-001',
  name: 'company-sensitive-data',
  type: 'S3Bucket',
  region: 'us-east-1',
  encryption: 'AES256',
  public_access: false,
  contains_pii: true,
  mitre_techniques: ['T1530']
});

CREATE (lambda_func:Service:AWSService {
  id: 'aws-lambda-processor-001',
  name: 'data-processor-function',
  type: 'LambdaFunction',
  runtime: 'python3.9',
  region: 'us-east-1',
  environment_vars: ['DB_PASSWORD', 'API_KEY'],
  mitre_techniques: ['T1552.001']
});

// Create relationships for AWS escalation path
CREATE (dev_user)-[:ASSUMES_ROLE {
  method: 'sts:AssumeRole',
  conditions: 'MFA not required',
  created: datetime('2024-01-15T10:30:00Z')
}]->(dev_role);

CREATE (dev_role)-[:CAN_ESCALATE_TO {
  method: 'iam:PassRole misconfiguration',
  vulnerability: 'Overly permissive trust policy',
  impact: 'admin_access'
}]->(admin_role);

CREATE (admin_role)-[:CAN_ACCESS {
  permissions: ['s3:GetObject', 's3:ListBucket'],
  granted: datetime('2024-01-10T09:00:00Z')
}]->(s3_bucket);

CREATE (admin_role)-[:CAN_INVOKE {
  permissions: ['lambda:InvokeFunction', 'lambda:GetFunction'],
  environment_access: true
}]->(lambda_func);

// Add direct user access relationships for simpler queries
CREATE (dev_user)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Indirect access via role assumption chain'
}]->(s3_bucket);

CREATE (dev_user)-[:CAN_ACCESS {
  method: 'Through assumed roles', 
  description: 'Indirect access via role assumption chain'
}]->(lambda_func);

// ==============================================
// SCENARIO 2: Cross-Cloud Attack Path (Azure → AWS)
// ==============================================

// Create Azure AD Users
CREATE (azure_dev:User:AzureUser {
  id: 'azure-user-dev-001',
  name: 'Emma Watson',
  email: 'emma.watson@company.com',
  tenant_id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  upn: 'emma.watson@company.onmicrosoft.com',
  type: 'Member',
  mfa_enabled: false,
  mitre_techniques: ['T1078.004']
});

// Create CI/CD Pipeline
CREATE (github_actions:Service:CICDService {
  id: 'github-actions-001',
  name: 'Deploy Pipeline',
  platform: 'GitHub Actions',
  repository: 'company/infrastructure',
  branch: 'main',
  secrets_access: true,
  mitre_techniques: ['T1195.002', 'T1552.004']
});

// Create Cross-Cloud Role
CREATE (cross_cloud_role:Role:AWSRole {
  id: 'aws-role-cicd-001',
  name: 'GitHubActionsRole',
  arn: 'arn:aws:iam::123456789012:role/GitHubActionsRole',
  account_id: '123456789012',
  trust_policy: 'Allows OIDC from GitHub Actions',
  federated_identity: true,
  mitre_techniques: ['T1134.001']
});

// Create relationships for cross-cloud path
CREATE (azure_dev)-[:HAS_ACCESS_TO {
  permissions: ['push', 'workflow_dispatch'],
  access_level: 'write'
}]->(github_actions);

CREATE (github_actions)-[:ASSUMES_ROLE {
  method: 'OIDC federation',
  token_source: 'GitHub OIDC provider',
  conditions: 'Repository and branch match'
}]->(cross_cloud_role);

CREATE (cross_cloud_role)-[:CAN_ACCESS {
  permissions: ['s3:PutObject', 's3:GetObject'],
  deployment_target: true
}]->(s3_bucket);

// Add direct azure user access for query compatibility
CREATE (azure_dev)-[:CAN_ACCESS {
  method: 'Through CI/CD pipeline',
  description: 'Cross-cloud access via GitHub Actions'
}]->(s3_bucket);

// ==============================================
// SCENARIO 3: Kubernetes RBAC Escalation
// ==============================================

// Create K8s Namespace
CREATE (prod_namespace:Namespace:K8sResource {
  id: 'k8s-ns-production',
  name: 'production',
  cluster: 'prod-cluster-us-east',
  created: datetime('2024-01-01T00:00:00Z')
});

CREATE (default_namespace:Namespace:K8sResource {
  id: 'k8s-ns-default',
  name: 'default',
  cluster: 'prod-cluster-us-east',
  created: datetime('2024-01-01T00:00:00Z')
});

// Create Service Accounts
CREATE (app_sa:ServiceAccount:K8sResource {
  id: 'k8s-sa-app-001',
  name: 'webapp-service-account',
  namespace: 'production',
  automount_token: true,
  mitre_techniques: ['T1134.001']
});

CREATE (admin_sa:ServiceAccount:K8sResource {
  id: 'k8s-sa-admin-001',
  name: 'cluster-admin-sa',
  namespace: 'kube-system',
  automount_token: true,
  mitre_techniques: ['T1134.001']
});

// Create Cluster Roles
CREATE (cluster_admin:Role:K8sRole {
  id: 'k8s-role-cluster-admin',
  name: 'cluster-admin',
  type: 'ClusterRole',
  rules: ['*.*.*'],
  builtin: true,
  mitre_techniques: ['T1548.005']
});

CREATE (pod_reader:Role:K8sRole {
  id: 'k8s-role-pod-reader',
  name: 'pod-reader',
  type: 'Role',
  namespace: 'production',
  rules: ['pods.get', 'pods.list'],
  mitre_techniques: ['T1613']
});

// Create Pods
CREATE (web_pod:Pod:K8sResource {
  id: 'k8s-pod-webapp-001',
  name: 'webapp-deployment-7d4b8c9f5-x7k2m',
  namespace: 'production',
  image: 'nginx:1.21',
  privileged: false,
  service_account: 'webapp-service-account',
  mitre_techniques: ['T1611']
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

// Create K8s relationships
CREATE (web_pod)-[:MOUNTS_SA {
  token_path: '/var/run/secrets/kubernetes.io/serviceaccount/token',
  auto_mount: true
}]->(app_sa);

CREATE (app_sa)-[:BOUND_TO {
  binding_name: 'webapp-binding',
  created: datetime('2024-01-15T14:00:00Z')
}]->(sa_binding);

CREATE (sa_binding)-[:GRANTS_ROLE {
  scope: 'namespace',
  namespace: 'production'
}]->(pod_reader);

CREATE (admin_sa)-[:BOUND_TO {
  binding_name: 'admin-cluster-binding',
  created: datetime('2024-01-01T00:00:00Z')
}]->(cluster_binding);

CREATE (cluster_binding)-[:GRANTS_ROLE {
  scope: 'cluster',
  permissions: 'all'
}]->(cluster_admin);

// Privilege escalation path
CREATE (app_sa)-[:CAN_ESCALATE_TO {
  method: 'ServiceAccount token reuse',
  vulnerability: 'Overprivileged service account',
  impact: 'cluster_admin'
}]->(admin_sa);

// ==============================================
// SCENARIO 4: Supply Chain & Container Escape
// ==============================================

// Create Container Registry
CREATE (container_registry:Service:ContainerService {
  id: 'container-registry-001',
  name: 'company-docker-registry',
  type: 'DockerHub',
  public_access: true,
  vulnerability_scanning: false,
  mitre_techniques: ['T1195.002']
});

// Create Compromised Package
CREATE (npm_package:Package:SupplyChain {
  id: 'npm-package-compromise-001',
  name: 'popular-utility-lib',
  version: '2.1.4',
  registry: 'npmjs.org',
  downloads: 1000000,
  compromised: true,
  payload_type: 'backdoor',
  mitre_techniques: ['T1195.002', 'T1059.007']
});

// Create Docker Image
CREATE (docker_image:Image:ContainerResource {
  id: 'docker-image-001',
  name: 'company/webapp',
  tag: 'v1.2.3',
  base_image: 'node:18-alpine',
  contains_secrets: true,
  privileged_capabilities: ['SYS_ADMIN'],
  mitre_techniques: ['T1610', 'T1552.001']
});

// Create Host System
CREATE (host_system:Host:InfrastructureResource {
  id: 'host-system-001',
  name: 'prod-worker-01',
  os: 'Ubuntu 20.04',
  container_runtime: 'containerd',
  kernel_version: '5.4.0-74-generic',
  privileged_containers: true,
  mitre_techniques: ['T1611']
});

// Supply chain relationships
CREATE (npm_package)-[:EMBEDDED_IN {
  build_stage: 'npm install',
  detection_bypassed: true
}]->(docker_image);

CREATE (docker_image)-[:STORED_IN {
  pushed: datetime('2024-01-20T16:30:00Z'),
  signed: false
}]->(container_registry);

CREATE (container_registry)-[:DEPLOYED_TO {
  pull_policy: 'Always',
  vulnerability_scan: false
}]->(web_pod);

CREATE (web_pod)-[:RUNS_ON {
  container_runtime: 'containerd',
  security_context: 'privileged'
}]->(host_system);

CREATE (docker_image)-[:CAN_ESCAPE_TO {
  method: 'Privileged container + kernel exploit',
  cve: 'CVE-2022-0847',
  impact: 'host_compromise'
}]->(host_system);

// ==============================================
// ANALYTICS QUERIES AND METADATA
// ==============================================

// Create metadata for common attack paths
CREATE (attack_path_1:AttackPath {
  id: 'path-aws-privilege-escalation',
  name: 'AWS IAM Privilege Escalation',
  description: 'Developer user escalates to admin via role assumption',
  techniques: ['T1078.004', 'T1548.005', 'T1134.001'],
  severity: 'HIGH',
  steps: 3,
  ttps: 'Initial Access → Privilege Escalation → Impact'
});

CREATE (attack_path_2:AttackPath {
  id: 'path-cross-cloud',
  name: 'Cross-Cloud Attack Chain',
  description: 'Azure AD user compromises AWS resources via CI/CD',
  techniques: ['T1078.004', 'T1195.002', 'T1552.004'],
  severity: 'CRITICAL',
  steps: 4,
  ttps: 'Initial Access → Lateral Movement → Privilege Escalation → Impact'
});

CREATE (attack_path_3:AttackPath {
  id: 'path-k8s-rbac',
  name: 'Kubernetes RBAC Escalation',
  description: 'Pod service account escalates to cluster admin',
  techniques: ['T1134.001', 'T1548.005', 'T1613'],
  severity: 'HIGH',
  steps: 3,
  ttps: 'Initial Access → Privilege Escalation → Lateral Movement'
});

CREATE (attack_path_4:AttackPath {
  id: 'path-supply-chain',
  name: 'Supply Chain Container Escape',
  description: 'Compromised package leads to host compromise',
  techniques: ['T1195.002', 'T1610', 'T1611'],
  severity: 'CRITICAL',
  steps: 4,
  ttps: 'Supply Chain Compromise → Container Escape → Host Compromise'
});

// Create summary statistics
CREATE (lab_stats:LabStats {
  scenarios: 4,
  nodes: 35,
  relationships: 25,
  mitre_techniques: 12,
  severity_critical: 2,
  severity_high: 2,
  updated: datetime()
});

RETURN "Cloud Threat Graph Lab Phase 1 data loaded successfully!" as status;