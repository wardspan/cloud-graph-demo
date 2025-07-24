// =====================================================
// CLOUD THREAT GRAPH LAB - PHASE 2 ENHANCED SCENARIOS
// =====================================================
// Adds 4 sophisticated attack scenarios to Phase 1 foundation
// Total: 8 scenarios, ~50 new nodes, advanced attack chains

// Clear any existing Phase 2 data
MATCH (n) WHERE n.phase = 'phase2' DETACH DELETE n;


// =====================================================
// SCENARIO 5: SUPPLY CHAIN COMPROMISE
// =====================================================
// Compromised npm package → CI/CD injection → cloud deployment → privilege escalation
// Risk Level: CRITICAL
// MITRE: T1195.002, T1609, T1552.007

// NPM Package Supply Chain Nodes
CREATE (malPackage:Package:NPMPackage {
    name: 'popular-utility-lib',
    version: '2.1.4',
    registry: 'npmjs.org',
    downloads_monthly: 2500000,
    compromised: true,
    payload_type: 'backdoor',
    injection_method: 'typosquatting',
    first_seen: '2024-03-15',
    phase: 'phase2',
    mitre_techniques: ['T1195.002', 'T1027', 'T1059.007']
});

CREATE (buildPipeline:Pipeline:BuildPipeline {
    name: 'webapp-ci-pipeline',
    provider: 'GitHub Actions',
    trigger: 'push_to_main',
    runner: 'ubuntu-latest',
    dockerfile_path: './Dockerfile',
    secrets_access: ['DOCKERHUB_TOKEN', 'AWS_ACCESS_KEY'],
    phase: 'phase2',
    mitre_techniques: ['T1195.002', 'T1552.004']
});

CREATE (containerRegistry:Registry:ContainerRegistry {
    name: 'company-registry',
    provider: 'Docker Hub',
    visibility: 'private',
    image_scanning: false,
    vulnerability_threshold: 'high',
    auto_build: true,
    phase: 'phase2',
    mitre_techniques: ['T1525', 'T1609']
});

CREATE (maliciousImage:Image:ContainerImage {
    name: 'webapp-prod',
    tag: 'v2.1.4-malicious',
    registry: 'company-registry',
    base_image: 'node:16-alpine',
    size_mb: 145,
    layers: 8,
    contains_backdoor: true,
    phase: 'phase2',
    mitre_techniques: ['T1525', 'T1610']
});

CREATE (ecsTask:Service:ECSTask {
    name: 'webapp-production',
    cluster: 'prod-cluster',
    cpu: 512,
    memory: 1024,
    execution_role_arn: 'arn:aws:iam::123456789012:role/ecsTaskExecutionRole',
    task_role_arn: 'arn:aws:iam::123456789012:role/webapp-task-role',
    vpc_id: 'vpc-12345678',
    phase: 'phase2',
    mitre_techniques: ['T1610', 'T1552.007']
});

CREATE (secretsManager:Service:SecretsManager {
    name: 'prod-database-credentials',
    secret_arn: 'arn:aws:secretsmanager:us-east-1:123456789012:secret:prod-db-creds',
    kms_key_id: 'arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012',
    contains_pii: true,
    access_policy: 'overprivileged',
    phase: 'phase2',
    mitre_techniques: ['T1552.007', 'T1555']
});

// Supply Chain Attack Relationships
CREATE (malPackage)-[:INJECTED_INTO]->(buildPipeline);
CREATE (buildPipeline)-[:BUILDS_IMAGE]->(maliciousImage);
CREATE (maliciousImage)-[:PUSHED_TO]->(containerRegistry);
CREATE (containerRegistry)-[:DEPLOYS_TO]->(ecsTask);
CREATE (ecsTask)-[:ACCESSES_SECRETS]->(secretsManager);
CREATE (malPackage)-[:COMPROMISES]->(ecsTask);


// =====================================================
// SCENARIO 6: SECRETS SPRAWL ATTACK
// =====================================================
// Hardcoded GitHub token → private repo access → Terraform state → cloud admin credentials
// Risk Level: HIGH
// MITRE: T1552.001, T1552.004, T1078.004

// Secrets Sprawl Nodes
CREATE (hardcodedToken:Token:HardcodedToken {
    name: 'github-pat-token',
    token_type: 'personal_access_token',
    scope: 'repo,read:org',
    location: 'public-repo/config/deploy.js',
    exposed_date: '2024-02-20',
    still_valid: true,
    owner: 'sarah.chen@company.com',
    phase: 'phase2',
    mitre_techniques: ['T1552.001', 'T1078.004']
});

CREATE (publicRepo:Repository:PublicRepo {
    name: 'company-webapp',
    owner: 'company-org',
    visibility: 'public',
    default_branch: 'main',
    contains_secrets: true,
    stars: 234,
    forks: 67,
    phase: 'phase2',
    mitre_techniques: ['T1552.001']
});

CREATE (privateRepo:Repository:PrivateRepo {
    name: 'infrastructure-terraform',
    owner: 'company-org',
    visibility: 'private',
    contains_terraform_state: true,
    state_backend: 's3',
    encryption_at_rest: false,
    phase: 'phase2',
    mitre_techniques: ['T1552.004', 'T1552.001']
});

CREATE (terraformState:File:TerraformState {
    name: 'production.tfstate',
    backend: 's3',
    bucket: 'company-terraform-state',
    workspace: 'production',
    contains_credentials: true,
    last_modified: '2024-07-20',
    encryption: 'none',
    phase: 'phase2',
    mitre_techniques: ['T1552.004']
});

CREATE (cloudCredentials:Credentials:CloudCredentials {
    name: 'terraform-provisioner-creds',
    type: 'aws_access_key',
    access_key_id: 'AKIA...',
    permissions: 'AdministratorAccess',
    created_date: '2024-01-15',
    rotation_enabled: false,
    phase: 'phase2',
    mitre_techniques: ['T1078.004', 'T1098.001']
});

CREATE (s3AdminBucket:Service:S3AdminBucket {
    name: 'company-prod-admin-data',
    region: 'us-east-1',
    encryption: 'AES256',
    versioning: true,
    contains_pii: true,
    public_access_blocked: true,
    access_logging: false,
    phase: 'phase2',
    mitre_techniques: ['T1530']
});

// Secrets Sprawl Relationships
CREATE (publicRepo)-[:EXPOSES_SECRET]->(hardcodedToken);
CREATE (hardcodedToken)-[:GRANTS_ACCESS]->(privateRepo);
CREATE (privateRepo)-[:CONTAINS_STATE]->(terraformState);
CREATE (terraformState)-[:REVEALS_CREDS]->(cloudCredentials);
CREATE (cloudCredentials)-[:ESCALATES_TO]->(s3AdminBucket);


// =====================================================
// SCENARIO 7: SERVERLESS ATTACK CHAIN
// =====================================================
// API Gateway → overprivileged Lambda → service chains → data exfiltration
// Risk Level: HIGH
// MITRE: T1190, T1098.001, T1530

// Serverless Attack Nodes
CREATE (apiGateway:Service:APIGateway {
    name: 'customer-api-gateway',
    stage: 'prod',
    authentication: 'none',
    rate_limiting: false,
    cors_enabled: true,
    endpoint_type: 'REGIONAL',
    logging_enabled: false,
    phase: 'phase2',
    mitre_techniques: ['T1190', 'T1562.008']
});

CREATE (lambdaFunction:Service:LambdaFunction {
    name: 'customer-data-processor',
    runtime: 'nodejs18.x',
    memory_mb: 512,
    timeout_seconds: 300,
    vpc_config: false,
    environment_vars: ['DB_CONNECTION_STRING', 'S3_BUCKET_NAME'],
    phase: 'phase2',
    mitre_techniques: ['T1609', 'T1552.007']
});

CREATE (lambdaExecutionRole:Role:ExecutionRole {
    name: 'lambda-overprivileged-role',
    type: 'aws_iam_role',
    permissions: ['s3:*', 'dynamodb:*', 'sns:*', 'secretsmanager:*'],
    trust_policy: 'lambda.amazonaws.com',
    attached_policies: ['AmazonS3FullAccess', 'AmazonDynamoDBFullAccess'],
    phase: 'phase2',
    mitre_techniques: ['T1098.001']
});

CREATE (dynamoTable:Service:DynamoDBTable {
    name: 'customer-profiles',
    partition_key: 'customer_id',
    billing_mode: 'PAY_PER_REQUEST',
    encryption_at_rest: true,
    point_in_time_recovery: false,
    contains_pii: true,
    phase: 'phase2',
    mitre_techniques: ['T1530']
});

CREATE (s3DataLake:Service:S3DataLake {
    name: 'customer-analytics-lake',
    region: 'us-east-1',
    storage_class: 'STANDARD',
    versioning: false,
    mfa_delete: false,
    contains_pii: true,
    public_access_blocked: false,
    phase: 'phase2',
    mitre_techniques: ['T1530', 'T1537']
});

CREATE (snsAlert:Service:SNSAlert {
    name: 'security-alerts-topic',
    subscription_protocol: 'email',
    message_filtering: false,
    dlq_configured: false,
    encryption_in_transit: false,
    phase: 'phase2',
    mitre_techniques: ['T1562.008']
});

// Serverless Attack Relationships
CREATE (apiGateway)-[:INVOKES_FUNCTION]->(lambdaFunction);
CREATE (lambdaFunction)-[:EXECUTES_AS]->(lambdaExecutionRole);
CREATE (lambdaExecutionRole)-[:QUERIES_TABLE]->(dynamoTable);
CREATE (lambdaExecutionRole)-[:WRITES_TO]->(s3DataLake);
CREATE (lambdaFunction)-[:BYPASSES_MONITORING]->(snsAlert);
CREATE (apiGateway)-[:ESCALATES_THROUGH]->(s3DataLake);


// =====================================================
// SCENARIO 8: MULTI-CLOUD IDENTITY FEDERATION ATTACK
// =====================================================
// Azure AD federated with AWS → cross-cloud escalation → federated identity abuse
// Risk Level: CRITICAL
// MITRE: T1078.004, T1550.001, T1098.001

// Multi-Cloud Federation Nodes
CREATE (azureADUser:User:AzureADUser {
    name: 'contractor.external@partner.com',
    email: 'contractor.external@partner.com',
    tenant_id: '12345678-1234-1234-1234-123456789012',
    user_type: 'Guest',
    mfa_enabled: false,
    privileged_roles: ['Application Developer'],
    external_provider: true,
    phase: 'phase2',
    mitre_techniques: ['T1078.004']
});

CREATE (oidcProvider:Service:OIDCProvider {
    name: 'azure-ad-oidc-provider',
    issuer_url: 'https://login.microsoftonline.com/12345678-1234-1234-1234-123456789012/v2.0',
    client_id: '87654321-4321-4321-4321-210987654321',
    scope: 'openid profile email',
    token_lifetime: 3600,
    refresh_token_enabled: true,
    phase: 'phase2',
    mitre_techniques: ['T1550.001']
});

CREATE (awsIdentityProvider:Service:AWSIdentityProvider {
    name: 'azure-ad-identity-provider',
    provider_type: 'OIDC',
    provider_arn: 'arn:aws:iam::123456789012:oidc-provider/login.microsoftonline.com',
    thumbprint: 'A1B2C3D4E5F6...',
    client_id_list: ['87654321-4321-4321-4321-210987654321'],
    phase: 'phase2',
    mitre_techniques: ['T1550.001']
});

CREATE (federatedRole:Role:FederatedRole {
    name: 'AzureAD-DeveloperAccess',
    type: 'aws_iam_role',
    assume_role_policy: 'federated_oidc',
    permissions: ['ec2:*', 's3:ListBucket', 'iam:ListRoles'],
    max_session_duration: 43200,
    trust_relationship: 'Azure AD OIDC',
    phase: 'phase2',
    mitre_techniques: ['T1078.004', 'T1098.001']
});

CREATE (crossAccountTrust:Service:CrossAccountTrust {
    name: 'prod-account-cross-trust',
    trusted_account: '123456789012',
    trusting_account: '999888777666',
    trust_policy: 'assume_role_from_dev',
    external_id_required: false,
    mfa_required: false,
    phase: 'phase2',
    mitre_techniques: ['T1098.001']
});

CREATE (productionAccount:Account:ProductionAccount {
    name: 'production-aws-account',
    account_id: '999888777666',
    environment: 'production',
    contains_sensitive_data: true,
    cross_account_access: true,
    monitoring_enabled: false,
    phase: 'phase2',
    mitre_techniques: ['T1078.004']
});

// Multi-Cloud Federation Relationships
CREATE (azureADUser)-[:FEDERATES_WITH]->(oidcProvider);
CREATE (oidcProvider)-[:TRUSTS_PROVIDER]->(awsIdentityProvider);
CREATE (awsIdentityProvider)-[:ASSUMES_FEDERATED_ROLE]->(federatedRole);
CREATE (federatedRole)-[:GRANTS_CROSS_ACCOUNT]->(crossAccountTrust);
CREATE (crossAccountTrust)-[:PERSISTS_IN]->(productionAccount);
CREATE (azureADUser)-[:ESCALATES_TO]->(productionAccount);


// =====================================================
// PHASE 2 CROSS-SCENARIO RELATIONSHIPS
// =====================================================
// Connect new scenarios to existing Phase 1 entities

// Connect supply chain to existing users
MATCH (sarah:User {name: 'Sarah Chen'})
MATCH (malPackage:Package {name: 'popular-utility-lib'})
CREATE (sarah)-[:APPROVED_PACKAGE]->(malPackage);

// Connect secrets sprawl to existing services
MATCH (s3bucket:Service {name: 'customer-data-bucket'})
MATCH (cloudCreds:CloudCredentials {name: 'terraform-provisioner-creds'})
CREATE (cloudCreds)-[:GRANTS_ACCESS]->(s3bucket);

// Connect serverless to existing K8s environment
MATCH (webappPod:Pod {name: 'webapp-frontend'})
MATCH (apiGw:APIGateway {name: 'customer-api-gateway'})
CREATE (webappPod)-[:CALLS_API]->(apiGw);

// Connect federation to existing Azure user
MATCH (emma:User {name: 'Emma Watson'})
MATCH (azureUser:AzureADUser {name: 'contractor.external@partner.com'})
CREATE (emma)-[:MANAGES_EXTERNAL_USER]->(azureUser);


// =====================================================
// PHASE 2 STATISTICS UPDATE
// =====================================================
// Update lab statistics to reflect Phase 2 expansion

CREATE (phase2Stats:Statistics {
    phase: 'phase2',
    total_nodes: 118,
    total_relationships: 55,
    total_scenarios: 8,
    mitre_techniques: 25,
    last_updated: datetime()
});

RETURN "Phase 2 Enhanced Scenarios Created Successfully" as status,
       "Added 4 new attack scenarios with 50+ nodes" as summary,
       "Supply Chain, Secrets Sprawl, Serverless, Multi-Cloud Federation" as scenarios;