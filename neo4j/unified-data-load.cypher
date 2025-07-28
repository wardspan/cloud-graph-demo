// =============================================================================
// CLOUD THREAT GRAPH LAB - UNIFIED DATA LOADER
// =============================================================================
// This single file loads ALL data for the lab in the correct order within
// a single transaction to ensure consistency and prevent race conditions.
//
// This replaces the multi-file approach that was causing data loading issues.
//

// Clear any existing data to ensure clean state
MATCH (n) DETACH DELETE n;

// =============================================================================
// FOUNDATION DATA - Basic Users, Roles, Services with Relationships
// =============================================================================

CREATE (dev_user:User:AWSUser {
  id: 'aws-user-dev-001',
  name: 'Sarah Chen',
  email: 'sarah.chen@company.com',
  access_level: 'developer',
  account_id: '123456789012',
  type: 'IAMUser'
}),

(admin_user:User:AWSUser {
  id: 'aws-user-admin-001', 
  name: 'Mike Rodriguez',
  email: 'mike.rodriguez@company.com',
  access_level: 'administrator',
  account_id: '123456789012',
  type: 'IAMUser'
}),

(azure_dev:User:AzureUser {
  id: 'azure-user-dev-001',
  name: 'Emma Watson',
  email: 'emma.watson@company.com',
  tenant_id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  upn: 'emma.watson@company.onmicrosoft.com',
  access_level: 'developer'
}),

// AWS Roles
(dev_role:Role:AWSRole {
  id: 'aws-role-dev-001',
  name: 'DeveloperRole',
  arn: 'arn:aws:iam::123456789012:role/DeveloperRole',
  account_id: '123456789012',
  type: 'IAMRole',
  permissions: ['s3:GetObject', 'lambda:InvokeFunction']
}),

(admin_role:Role:AWSRole {
  id: 'aws-role-admin-001',
  name: 'AdminRole', 
  arn: 'arn:aws:iam::123456789012:role/AdminRole',
  account_id: '123456789012',
  type: 'IAMRole',
  permissions: ['iam:*', 's3:*', 'ec2:*']
}),

(cross_cloud_role:Role:AWSRole {
  id: 'aws-role-cicd-001',
  name: 'GitHubActionsRole',
  arn: 'arn:aws:iam::123456789012:role/GitHubActionsRole',
  account_id: '123456789012',
  type: 'IAMRole',
  permissions: ['s3:PutObject', 's3:GetObject']
}),

// AWS Services
(s3_bucket:Service:AWSService {
  id: 'aws-s3-sensitive-001',
  name: 'company-sensitive-data',
  type: 'S3Bucket',
  region: 'us-east-1',
  contains_pii: true,
  encryption: 'AES256'
}),

(lambda_func:Service:AWSService {
  id: 'aws-lambda-processor-001',
  name: 'data-processor-function', 
  type: 'LambdaFunction',
  runtime: 'python3.9',
  region: 'us-east-1',
  contains_pii: false
}),

(github_actions:Service:CICDService {
  id: 'github-actions-001',
  name: 'Deploy Pipeline',
  platform: 'GitHub Actions',
  repository: 'company/infrastructure',
  type: 'CICDPipeline'
}),

// =============================================================================
// PHASE 2 ENHANCED SCENARIOS DATA
// =============================================================================

// Supply Chain Components
(npm_package:Package:NPMPackage {
  id: 'npm-package-001',
  name: 'popular-utility-lib',
  version: '2.1.4',
  registry: 'npmjs.org',
  compromised: true,
  payload_type: 'backdoor'
}),

(secrets_mgr:SecretsManager {
  id: 'secrets-mgr-001',
  name: 'prod-database-credentials',
  region: 'us-east-1',
  contains_pii: true,
  encryption: 'AWS_KMS'
}),

// Serverless Components
(api_gateway:APIGateway {
  id: 'api-gateway-001',
  name: 'customer-api-gateway',
  stage: 'prod',
  authentication: 'none',
  public_access: true
}),

(data_lake:S3DataLake {
  id: 's3-data-lake-001',
  name: 'customer-analytics-lake',
  type: 'S3Bucket',
  contains_pii: true,
  public_access_blocked: false
}),

(lambda_role:Role:AWSRole {
  id: 'lambda-role-001',
  name: 'lambda-overprivileged-role',
  arn: 'arn:aws:iam::123456789012:role/lambda-overprivileged-role',
  permissions: ['s3:*', 'dynamodb:*'],
  overprivileged: true
}),

// Secrets Sprawl Components
(hardcoded_token:HardcodedToken {
  id: 'token-001',
  name: 'github-personal-access-token',
  location: 'public-repo:config.js',
  still_valid: true,
  scope: 'repo:admin'
}),

(admin_bucket:S3AdminBucket {
  id: 's3-admin-001',
  name: 'company-prod-admin-data',
  type: 'S3Bucket',
  contains_pii: true,
  admin_access: true,
  terraform_managed: true
}),

// Multi-Cloud Federation
(azure_contractor:AzureUser:AzureADUser {
  id: 'azure-contractor-001',
  name: 'contractor.external@partner.com',
  email: 'contractor.external@partner.com',
  user_type: 'Guest',
  mfa_enabled: false,
  external_user: true
}),

(oidc_provider:OIDCProvider {
  id: 'oidc-001',
  name: 'azure-aws-federation',
  issuer: 'https://sts.windows.net/tenant-id',
  audience: 'aws-account-123456789012'
}),

(prod_account:ProductionAccount {
  id: 'prod-account-001',
  name: 'aws-production-account',
  account_id: '123456789012',
  contains_sensitive_data: true
}),

// Container Components
(container_image:ContainerImage {
  id: 'container-001',
  name: 'company/webapp:compromised',
  base: 'node:18-alpine',
  contains_malware: true
}),

(host_system:Host {
  id: 'host-001',
  name: 'prod-worker-01',
  os: 'Ubuntu 20.04',
  container_runtime: 'containerd',
  kernel_version: '5.4.0-74-generic'
}),

// Kubernetes Components
(k8s_pod:K8sResource {
  id: 'k8s-pod-001',
  name: 'webapp-pod',
  namespace: 'production',
  type: 'Pod'
}),

(k8s_admin_role:Role:K8sRole {
  id: 'k8s-role-001',
  name: 'cluster-admin',
  type: 'ClusterRole',
  rules: ['*.*.*'],
  builtin: true
}),

// =============================================================================
// CARTOGRAPHY DISCOVERY DATA
// =============================================================================

(discovered_ec2:AWSService {
  id: 'discovered-ec2-001',
  name: 'web-server-discovered',
  type: 'EC2',
  cloud_provider: 'AWS',
  discovered_via_cartography: true,
  discovery_time: datetime('2024-01-15T10:31:00Z'),
  contains_pii: true,
  security_risk: 'HIGH',
  risk_reason: 'Instance has admin IAM role attached'
}),

(discovered_role:AWSRole {
  id: 'discovered-role-001',
  name: 'EC2AdminRole-discovered',
  cloud_provider: 'AWS',
  discovered_via_cartography: true,
  discovery_time: datetime('2024-01-15T10:32:00Z'),
  permissions: ['ec2:*', 's3:*', 'iam:*'],
  security_risk: 'CRITICAL',
  risk_reason: 'Overprivileged role with admin permissions'
}),

(discovered_s3:AWSService {
  id: 'discovered-s3-001',
  name: 'customer-data-discovered',
  type: 'S3Bucket',
  cloud_provider: 'AWS',
  discovered_via_cartography: true,
  discovery_time: datetime('2024-01-15T10:33:00Z'),
  contains_pii: true,
  public_access_blocked: false,
  security_risk: 'CRITICAL',
  risk_reason: 'Bucket contains PII and has public access'
}),

(discovered_contractor:AzureUser:AzureADUser {
  id: 'discovered-contractor-001',
  name: 'contractor-discovered',
  cloud_provider: 'Azure',
  discovered_via_cartography: true,
  discovery_time: datetime('2024-01-15T11:00:00Z'),
  user_type: 'Guest',
  mfa_enabled: false,
  security_risk: 'HIGH',
  risk_reason: 'External contractor without MFA'
}),

(discovered_federation:TrustRelationship {
  id: 'trust-001',
  name: 'azure-aws-federation',
  source_cloud: 'Azure',
  target_cloud: 'AWS',
  discovered_via_cartography: true,
  discovery_time: datetime('2024-01-15T11:01:00Z'),
  trust_type: 'OIDC_Federation',
  security_risk: 'MEDIUM',
  risk_reason: 'Cross-cloud trust relationship'
}),

(discovered_aws_role:AWSRole {
  id: 'discovered-aws-role-001',
  name: 'FederatedRole-discovered',
  cloud_provider: 'AWS',
  discovered_via_cartography: true,
  discovery_time: datetime('2024-01-15T11:02:00Z'),
  permissions: ['s3:GetObject', 'ec2:DescribeInstances'],
  federated_access: true,
  security_risk: 'MEDIUM',
  risk_reason: 'Role accessible via federation'
}),

// =============================================================================
// ALL RELATIONSHIPS - Foundation Attack Paths
// =============================================================================

// AWS Basic Attack Paths
(dev_user)-[:ASSUMES_ROLE {
  method: 'sts:AssumeRole',
  conditions: 'MFA not required'
}]->(dev_role),

(dev_role)-[:CAN_ESCALATE_TO {
  method: 'iam:PassRole misconfiguration',
  vulnerability: 'Overly permissive trust policy'
}]->(admin_role),

(admin_role)-[:CAN_ACCESS {
  permissions: ['s3:GetObject', 's3:ListBucket'],
  access_type: 'full'
}]->(s3_bucket),

(admin_role)-[:CAN_ACCESS {
  permissions: ['lambda:InvokeFunction', 'lambda:GetFunction'],
  access_type: 'execute'
}]->(lambda_func),

// Direct access paths for queries
(dev_user)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Via role escalation chain'
}]->(s3_bucket),

(dev_user)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Via role escalation chain'
}]->(lambda_func),

// Cross-cloud relationships
(azure_dev)-[:HAS_ACCESS_TO {
  permissions: ['push', 'workflow_dispatch'],
  access_level: 'write'
}]->(github_actions),

(github_actions)-[:ASSUMES_ROLE {
  method: 'OIDC federation',
  token_source: 'GitHub OIDC provider'
}]->(cross_cloud_role),

(cross_cloud_role)-[:CAN_ACCESS {
  permissions: ['s3:PutObject', 's3:GetObject'],
  deployment_target: true
}]->(s3_bucket),

(azure_dev)-[:CAN_ACCESS {
  method: 'Through CI/CD pipeline',  
  description: 'Cross-cloud access via GitHub Actions'
}]->(s3_bucket),

// =============================================================================
// ENHANCED SCENARIO RELATIONSHIPS
// =============================================================================

// Supply Chain Attack Paths
(npm_package)-[:EMBEDDED_IN {
  build_stage: 'npm install',
  detection_bypassed: true,
  injection_method: 'dependency confusion'
}]->(github_actions),

(github_actions)-[:ACCESSES_SECRETS {
  method: 'ECS task execution role',
  permissions: 'secretsmanager:GetSecretValue'
}]->(secrets_mgr),

// Serverless Attack Chain
(api_gateway)-[:TRIGGERS {
  method: 'HTTP invocation',
  authentication: 'none'
}]->(lambda_role),

(lambda_role)-[:CAN_ACCESS {
  permissions: ['s3:GetObject', 's3:ListBucket'],
  data_classification: 'PII'
}]->(data_lake),

// Secrets Sprawl
(hardcoded_token)-[:GRANTS_ACCESS_TO {
  method: 'GitHub API authentication',
  scope: 'repo:admin',
  escalation_path: 'via terraform state'
}]->(admin_bucket),

// Multi-Cloud Federation
(azure_contractor)-[:FEDERATED_THROUGH {
  trust_relationship: 'OIDC',
  mfa_required: false,
  external_user: true
}]->(oidc_provider),

(oidc_provider)-[:GRANTS_ACCESS_TO {
  method: 'AssumeRoleWithWebIdentity',
  cross_account: true
}]->(prod_account),

// Container Escape
(npm_package)-[:EMBEDDED_IN {
  build_stage: 'npm install',
  detection_bypassed: true
}]->(container_image),

(container_image)-[:DEPLOYED_TO {
  runtime: 'containerd',
  security_context: 'privileged'
}]->(host_system),

// Kubernetes RBAC
(k8s_pod)-[:ESCALATES_TO {
  method: 'ServiceAccount token reuse',
  vulnerability: 'Overprivileged RBAC binding',
  technique: 'T1134.001'
}]->(k8s_admin_role),

// =============================================================================
// CARTOGRAPHY DISCOVERY RELATIONSHIPS
// =============================================================================

(discovered_ec2)-[:ASSUMES_ROLE {
  method: 'instance metadata', 
  discovered: true
}]->(discovered_role),

(discovered_role)-[:CAN_ACCESS {
  permissions: ['s3:*'], 
  discovered: true
}]->(discovered_s3),

(discovered_contractor)-[:USES_FEDERATION {
  discovered: true
}]->(discovered_federation),

(discovered_federation)-[:GRANTS_ROLE {
  discovered: true
}]->(discovered_aws_role),

(discovered_aws_role)-[:ACCESSES_DATA {
  discovered: true
}]->(discovered_s3);

// =============================================================================
// VERIFICATION AND COMPLETION
// =============================================================================

// Count verification
MATCH (n) 
WITH count(n) as total_nodes
MATCH ()-[r]->()
WITH total_nodes, count(r) as total_relationships
MATCH (u:User)-[:CAN_ACCESS]->(s:Service)
WITH total_nodes, total_relationships, count(DISTINCT u) as users_with_access

RETURN 
  total_nodes as TotalNodes,
  total_relationships as TotalRelationships, 
  users_with_access as UsersWithDirectAccess,
  "🚀 Cloud Threat Graph Lab - All Data Loaded Successfully!" as Status,
  "✅ 10 Scenarios Ready | ✅ Attack Paths Connected | ✅ Discovery Assets Ready" as Summary;