# 🎯 Attack Scenarios - Complete Documentation

## Overview
This document provides comprehensive details for all 8 attack scenarios in Phase 2 of the Cloud Threat Graph Lab. Each scenario includes technical details, MITRE ATT&CK mappings, detection methods, and mitigation strategies.

---

## Phase 1 Scenarios (Foundation)

### 1. 🔐 AWS Privilege Escalation
**Risk Level:** HIGH  
**MITRE Techniques:** T1078.004, T1548.005, T1134.001

#### Scenario Description
A developer user escalates privileges to admin level through IAM role assumption chains, gaining access to sensitive S3 buckets containing PII data.

#### Attack Path
1. **Initial Access**: Developer user 'Sarah Chen' has legitimate AWS console access
2. **Privilege Escalation**: Assumes 'PowerUserRole' through misconfigured trust policy
3. **Persistence**: Role grants access to sensitive S3 buckets with customer data

#### Key Entities
- **User**: Sarah Chen (developer access level)
- **Role**: PowerUserRole (PowerUser permissions)
- **Target**: customer-data-bucket (contains PII)

#### MITRE ATT&CK Details
- **T1078.004 (Valid Accounts: Cloud Accounts)**: Legitimate AWS account with escalation potential
- **T1548.005 (Temporary Elevated Cloud Access)**: IAM role assumption for privilege escalation
- **T1134.001 (Access Token Manipulation)**: STS token manipulation for role assumption

#### Detection Methods
- Monitor AssumeRole API calls from developer accounts
- Alert on cross-role access to sensitive resources
- Track unusual S3 access patterns from escalated roles

#### Mitigation Strategies
- Implement least-privilege IAM policies
- Require MFA for role assumption
- Use AWS Config for policy compliance monitoring
- Regular access reviews and role cleanup

---

### 2. ☁️ Cross-Cloud Attack Chain
**Risk Level:** CRITICAL  
**MITRE Techniques:** T1078.004, T1195.002, T1552.004

#### Scenario Description
Azure AD user leverages CI/CD pipeline integration to compromise AWS resources through federated access and supply chain injection.

#### Attack Path
1. **Initial Access**: Azure AD user 'Emma Watson' accesses GitHub Actions workflow
2. **Supply Chain**: Compromises CI/CD pipeline with malicious deployment code
3. **Cross-Cloud Access**: Pipeline assumes AWS role via OIDC federation
4. **Data Access**: Gains access to AWS S3 buckets through deployment permissions

#### Key Entities
- **User**: Emma Watson (Azure AD, DevOps Engineer)
- **Pipeline**: GitHub Actions workflow (cross-cloud deployment)
- **Federation**: OIDC provider (Azure AD → AWS trust)
- **Target**: AWS S3 services (production data)

#### MITRE ATT&CK Details
- **T1078.004 (Valid Accounts: Cloud Accounts)**: Legitimate Azure AD account access
- **T1195.002 (Compromise Software Supply Chain)**: CI/CD pipeline compromise
- **T1552.004 (Unsecured Credentials: Private Keys)**: OIDC token abuse for cross-cloud access

#### Detection Methods
- Monitor OIDC token usage across cloud boundaries
- Track unusual CI/CD deployment patterns
- Alert on cross-cloud resource access from pipelines

#### Mitigation Strategies
- Implement pipeline security scanning
- Use short-lived OIDC tokens with scope limitations
- Network segmentation between cloud environments
- Conditional access policies for CI/CD systems

---

### 3. ☸️ Kubernetes RBAC Escalation
**Risk Level:** HIGH  
**MITRE Techniques:** T1134.001, T1548.005, T1613

#### Scenario Description
Pod service account escalates to cluster-admin privileges through misconfigured RBAC bindings, gaining broad cluster access.

#### Attack Path
1. **Initial Access**: Pod 'webapp-frontend' runs with service account
2. **Discovery**: Service account token mounted in pod filesystem
3. **Escalation**: Service account bound to overprivileged ClusterRole
4. **Persistence**: Cluster-admin access to all Kubernetes resources

#### Key Entities
- **Pod**: webapp-frontend (production namespace)
- **ServiceAccount**: webapp-sa (overprivileged)
- **RoleBinding**: Grants cluster-admin access
- **Target**: Kubernetes cluster (full admin access)

#### MITRE ATT&CK Details
- **T1134.001 (Access Token Manipulation)**: Service account token theft and impersonation
- **T1548.005 (Abuse Elevation Control Mechanism)**: RBAC privilege escalation
- **T1613 (Container and Resource Discovery)**: Kubernetes cluster enumeration

#### Detection Methods
- Monitor service account token usage patterns
- Alert on escalated API server requests
- Track cluster-admin role binding changes

#### Mitigation Strategies
- Implement least-privilege RBAC policies
- Use Pod Security Standards/Policies
- Regular RBAC audit and cleanup
- Service account token rotation

---

### 4. 📦 Supply Chain Container Escape
**Risk Level:** CRITICAL  
**MITRE Techniques:** T1195.002, T1610, T1611

#### Scenario Description
Compromised npm package embedded in container image leads to container escape and host system compromise through privileged container execution.

#### Attack Path
1. **Supply Chain**: Malicious 'popular-utility-lib' npm package introduced
2. **Container Build**: Package included in application container image
3. **Deployment**: Container deployed to Kubernetes with privileged access
4. **Container Escape**: Malicious code breaks out to host system

#### Key Entities
- **Package**: popular-utility-lib (compromised npm package)
- **Image**: webapp container (contains malicious package)
- **Pod**: Privileged container (allows host access)
- **Target**: Host system (full compromise)

#### MITRE ATT&CK Details
- **T1195.002 (Supply Chain Compromise)**: Malicious package in software supply chain
- **T1610 (Deploy Container)**: Container deployment for persistence
- **T1611 (Escape to Host)**: Container breakout to host system

#### Detection Methods
- Software composition analysis (SCA) scanning
- Container runtime monitoring for escape attempts
- Host-based detection for privilege escalation

#### Mitigation Strategies
- Package vulnerability scanning and SBOMs
- Container security policies and admission controllers
- Runtime security monitoring
- Least-privilege container configurations

---

## Phase 2 Scenarios (Enhanced)

### 5. 🏭 Supply Chain Compromise
**Risk Level:** CRITICAL  
**MITRE Techniques:** T1195.002, T1609, T1552.007

#### Scenario Description
Comprehensive supply chain attack where compromised npm package flows through CI/CD pipeline to cloud deployment, accessing production secrets through container orchestration.

#### Attack Path
1. **Package Compromise**: 'popular-utility-lib' v2.1.4 compromised via typosquatting
2. **CI/CD Injection**: GitHub Actions pipeline builds compromised container
3. **Container Registry**: Malicious image pushed to company registry without scanning
4. **Cloud Deployment**: ECS task deploys compromised container with elevated IAM role
5. **Secrets Access**: Container accesses AWS Secrets Manager with production credentials

#### Key Entities
- **NPMPackage**: popular-utility-lib (2.5M monthly downloads, backdoor payload)
- **BuildPipeline**: webapp-ci-pipeline (GitHub Actions, secrets access)
- **ContainerRegistry**: company-registry (private, no vulnerability scanning)
- **ECSTask**: webapp-production (elevated IAM role permissions)
- **SecretsManager**: prod-database-credentials (contains PII access keys)

#### MITRE ATT&CK Details
- **T1195.002 (Compromise Software Supply Chain)**: Npm package typosquatting attack
- **T1609 (Container Administration Command)**: Container execution with elevated privileges  
- **T1552.007 (Unsecured Credentials: Container API)**: Container metadata service credential access

#### Detection Methods
- Package integrity monitoring and SBOM analysis
- CI/CD pipeline anomaly detection for unusual builds
- Container image vulnerability scanning with policy enforcement
- Runtime monitoring for unusual container API access patterns
- Secrets Manager access logging and alerting

#### Mitigation Strategies
- Software composition analysis with automatic vulnerability detection
- Secure CI/CD pipelines with isolated build environments
- Container image signing and admission control policies
- Least-privilege IAM roles for container execution
- Secrets rotation and just-in-time access policies

---

### 6. 🔑 Secrets Sprawl Attack
**Risk Level:** HIGH  
**MITRE Techniques:** T1552.001, T1552.004, T1078.004

#### Scenario Description
Hardcoded GitHub personal access token in public repository leads to private infrastructure repository access, Terraform state file exposure, and cloud admin credentials compromise.

#### Attack Path
1. **Secret Exposure**: GitHub PAT token hardcoded in public repository config file
2. **Repository Access**: Token grants read access to private infrastructure repository
3. **State File Access**: Private repo contains unencrypted Terraform state files
4. **Credential Extraction**: Terraform state reveals AWS admin access keys
5. **Cloud Escalation**: Admin credentials provide full access to production S3 buckets

#### Key Entities
- **HardcodedToken**: github-pat-token (repo scope, still valid, public exposure)
- **PublicRepo**: company-webapp (234 stars, contains exposed secrets)
- **PrivateRepo**: infrastructure-terraform (contains state files, no encryption)
- **TerraformState**: production.tfstate (unencrypted, contains credentials)
- **CloudCredentials**: terraform-provisioner-creds (AdministratorAccess permissions)
- **S3AdminBucket**: company-prod-admin-data (PII data, admin access only)

#### MITRE ATT&CK Details
- **T1552.001 (Unsecured Credentials: Credentials In Files)**: Hardcoded tokens in source code
- **T1552.004 (Unsecured Credentials: Private Keys)**: Terraform state credential exposure
- **T1078.004 (Valid Accounts: Cloud Accounts)**: Legitimate cloud account compromise

#### Detection Methods
- Secret scanning in source code repositories and commits
- GitHub audit log monitoring for unusual repository access
- Terraform state file integrity and encryption monitoring
- Cloud credential usage anomaly detection
- S3 access pattern analysis for admin bucket access

#### Mitigation Strategies
- Automated secret detection and remediation in repositories
- Secrets management systems (HashiCorp Vault, AWS Secrets Manager)
- Terraform remote state with encryption and access controls
- Regular credential rotation and access key lifecycle management
- Repository access controls and branch protection policies

---

### 7. ⚡ Serverless Attack Chain
**Risk Level:** HIGH  
**MITRE Techniques:** T1190, T1098.001, T1530

#### Scenario Description
Unauthenticated API Gateway endpoint exploitation leads through overprivileged Lambda function to data exfiltration from customer data lakes and DynamoDB tables.

#### Attack Path
1. **Initial Access**: Customer API Gateway endpoint lacks authentication controls  
2. **Function Execution**: API Gateway triggers Lambda with overprivileged execution role
3. **Privilege Abuse**: Lambda execution role has full S3 and DynamoDB access
4. **Data Discovery**: Function queries customer-profiles DynamoDB table (PII data)
5. **Data Exfiltration**: Writes customer data to publicly accessible S3 data lake
6. **Monitoring Bypass**: SNS alerting disabled, no security monitoring

#### Key Entities
- **APIGateway**: customer-api-gateway (no authentication, CORS enabled)
- **LambdaFunction**: customer-data-processor (512MB, 5min timeout)
- **ExecutionRole**: lambda-overprivileged-role (S3:*, DynamoDB:*, SNS:*)
- **DynamoDBTable**: customer-profiles (PII data, pay-per-request)
- **S3DataLake**: customer-analytics-lake (public access, no encryption)
- **SNSAlert**: security-alerts-topic (no DLQ, no encryption)

#### MITRE ATT&CK Details
- **T1190 (Exploit Public-Facing Application)**: Unauthenticated API Gateway exploitation
- **T1098.001 (Additional Cloud Credentials)**: Overprivileged IAM role abuse
- **T1530 (Data from Cloud Storage Object)**: Customer data exfiltration from S3

#### Detection Methods
- API Gateway request rate and pattern anomaly detection
- Lambda function execution monitoring for unusual data access
- DynamoDB access pattern analysis for bulk data reads
- S3 access logging for data lake write operations
- CloudTrail monitoring for IAM role assumption patterns

#### Mitigation Strategies
- API Gateway authentication and authorization (Cognito, Lambda authorizers)
- Least-privilege IAM roles for Lambda execution
- DynamoDB fine-grained access controls and encryption
- S3 bucket policies with principle of least privilege
- Real-time security monitoring and alerting systems

---

### 8. 🌐 Multi-Cloud Identity Federation Attack
**Risk Level:** CRITICAL  
**MITRE Techniques:** T1078.004, T1550.001, T1098.001

#### Scenario Description
External Azure AD guest user without MFA exploits federated identity trust to gain cross-cloud access to AWS production accounts containing sensitive data through OIDC provider weaknesses.

#### Attack Path
1. **Initial Access**: External contractor account in Azure AD with guest privileges
2. **MFA Bypass**: Guest account lacks MFA enforcement policies
3. **OIDC Federation**: Azure AD federates with AWS via OIDC provider
4. **Token Exchange**: OIDC provider issues AWS-compatible access tokens
5. **Role Assumption**: Federated role assumes cross-account production access
6. **Data Access**: Production account contains sensitive customer and business data

#### Key Entities
- **AzureADUser**: contractor.external@partner.com (Guest user, no MFA)
- **OIDCProvider**: azure-ad-oidc-provider (3600s token lifetime, refresh enabled)
- **AWSIdentityProvider**: azure-ad-identity-provider (no external ID requirement)
- **FederatedRole**: AzureAD-DeveloperAccess (12hr session, EC2/S3 permissions)
- **CrossAccountTrust**: prod-account-cross-trust (no MFA requirement)
- **ProductionAccount**: production-aws-account (sensitive data, cross-account access)

#### MITRE ATT&CK Details
- **T1078.004 (Valid Accounts: Cloud Accounts)**: Legitimate federated cloud account access
- **T1550.001 (Application Access Token)**: OIDC token abuse for cross-cloud authentication  
- **T1098.001 (Additional Cloud Credentials)**: Cross-account role assumption for persistence

#### Detection Methods
- Azure AD sign-in log analysis for guest user patterns
- OIDC token issuance monitoring for unusual federation requests
- AWS CloudTrail monitoring for federated role assumptions
- Cross-account access pattern analysis and anomaly detection
- Multi-cloud identity governance and access reviews

#### Mitigation Strategies
- Conditional access policies requiring MFA for guest users
- OIDC provider configuration with external ID and audience restrictions
- Time-limited federated role sessions with just-in-time access
- Cross-account trust policies with MFA and IP restrictions
- Regular federated identity access reviews and governance

---

## Cross-Scenario Analysis Queries

### Most Common MITRE Techniques
```cypher
MATCH (scenario:Scenario)-[:CONTAINS_STEP]->(step:AttackStep)-[:USES_TECHNIQUE]->(technique:MITRETechnique)
WITH technique, collect(DISTINCT scenario.name) as scenarios
WHERE size(scenarios) > 1
RETURN technique.technique_id, technique.technique_name, scenarios, size(scenarios) as usage_count
ORDER BY usage_count DESC
```

### Supply Chain Risk Assessment
```cypher
MATCH path = (package:NPMPackage)-[*]->(sensitive:SensitiveData)
RETURN path, 
       length(path) as attack_steps,
       [node in nodes(path) | node.type] as attack_chain,
       [rel in relationships(path) | type(rel)] as attack_methods
ORDER BY attack_steps ASC
```

### Multi-Cloud Attack Surface
```cypher
MATCH (azure:AzureResource)-[*]->(aws:AWSResource {privilege_level: "admin"})
WHERE azure.cloud_provider = "Azure" AND aws.cloud_provider = "AWS"
RETURN azure.name as starting_point, 
       aws.name as target,
       length(path) as escalation_steps
```

### Privilege Escalation Chains
```cypher
MATCH path = (start)-[*2..5]->(admin)
WHERE start.access_level = "developer" AND admin.privilege_level = "admin"
RETURN start.name, admin.name, length(path) as escalation_steps,
       [node in nodes(path) | labels(node)[0]] as escalation_types
ORDER BY escalation_steps ASC
```

---

## Detection and Mitigation Summary

### Top Detection Priorities
1. **Supply Chain Monitoring**: Package integrity, CI/CD anomalies, container scanning
2. **Identity Federation**: Cross-cloud access patterns, OIDC token abuse
3. **Privilege Escalation**: Role assumption chains, service account misuse
4. **Secrets Management**: Hardcoded credentials, state file exposure
5. **API Security**: Unauthenticated endpoints, overprivileged functions

### Key Mitigation Strategies
1. **Zero Trust Architecture**: Verify every access request regardless of location
2. **Least Privilege Access**: Minimal permissions for all identities and services
3. **Defense in Depth**: Multiple security layers across the entire stack
4. **Continuous Monitoring**: Real-time detection and automated response
5. **Security by Design**: Build security into CI/CD and infrastructure as code

### MITRE ATT&CK Coverage
- **Total Techniques Covered**: 25 across 11 tactics
- **Most Common Tactics**: Initial Access, Privilege Escalation, Credential Access
- **Detection Coverage**: 100% of techniques have detection methods
- **Mitigation Coverage**: 100% of techniques have mitigation strategies