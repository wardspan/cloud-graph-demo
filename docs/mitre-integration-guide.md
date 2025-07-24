# ⚔️ MITRE ATT&CK Integration Guide

## Overview
This guide provides comprehensive documentation for the MITRE ATT&CK framework integration in Phase 2 of the Cloud Threat Graph Lab. The lab now includes 25 techniques across 11 tactics with full mappings to attack scenarios.

---

## MITRE ATT&CK Framework Structure

### Tactics (Strategic Objectives)
The lab covers 11 MITRE ATT&CK tactics representing the adversary's strategic goals:

| Tactic ID | Tactic Name | Description | Scenarios Using |
|-----------|-------------|-------------|-----------------|
| TA0001 | Initial Access | Getting into your network | 4 scenarios |
| TA0002 | Execution | Running malicious code | 3 scenarios |
| TA0003 | Persistence | Maintaining foothold | 5 scenarios |
| TA0004 | Privilege Escalation | Gaining higher permissions | 6 scenarios |
| TA0005 | Defense Evasion | Avoiding detection | 3 scenarios |
| TA0006 | Credential Access | Stealing credentials | 5 scenarios |
| TA0007 | Discovery | Learning about environment | 2 scenarios |
| TA0008 | Lateral Movement | Moving through environment | 3 scenarios |
| TA0009 | Collection | Gathering target data | 2 scenarios |
| TA0010 | Exfiltration | Stealing data | 2 scenarios |
| TA0040 | Impact | Disrupting operations | 1 scenario |

### Techniques (Specific Methods)
25 techniques are implemented with full detection and mitigation guidance:

---

## Initial Access (TA0001)

### T1190 - Exploit Public-Facing Application
**Used in:** Serverless Attack Chain

**Description:** Adversaries exploit weaknesses in Internet-facing applications.
**Lab Example:** Unauthenticated API Gateway endpoint exploitation
**Platforms:** Windows, Linux, macOS, Network, Containers
**Data Sources:** Application Log, Web Credential

**Detection Methods:**
- Web application firewall (WAF) monitoring
- API Gateway request pattern analysis
- Unusual endpoint access monitoring
- Rate limiting and anomaly detection

**Mitigation Strategies:**
- Regular application security testing
- Input validation and sanitization
- Network segmentation and firewalls
- API authentication and authorization

### T1078 - Valid Accounts
**Used in:** AWS Privilege Escalation, Cross-Cloud Attack Chain, Multi-Cloud Federation

**Description:** Adversaries use legitimate accounts for initial access.
**Lab Example:** Sarah Chen's developer AWS account
**Platforms:** Windows, Linux, macOS, SaaS, IaaS, Network
**Data Sources:** Logon Session, Authentication Logs

**Detection Methods:**
- Behavioral analytics for account usage
- Privileged account monitoring
- Login anomaly detection
- Impossible travel analysis

**Mitigation Strategies:**
- Multi-factor authentication (MFA)
- Privileged access management (PAM)
- Regular access reviews
- Account lifecycle management

### T1078.004 - Valid Accounts: Cloud Accounts
**Used in:** AWS Privilege Escalation, Cross-Cloud Attack Chain, Secrets Sprawl, Multi-Cloud Federation

**Description:** Adversaries use cloud account credentials for access.
**Lab Example:** Azure AD contractor account, AWS developer credentials
**Platforms:** IaaS, SaaS
**Data Sources:** Logon Session, User Account

**Detection Methods:**
- Cloud authentication log analysis
- Cross-region access monitoring
- Unusual API usage patterns
- Service account activity tracking

**Mitigation Strategies:**
- Cloud Access Security Broker (CASB)
- Conditional access policies
- Privileged identity management
- Cloud security posture management

---

## Execution (TA0002)

### T1059.007 - Command and Scripting Interpreter: JavaScript
**Used in:** Supply Chain Compromise

**Description:** Adversaries abuse JavaScript implementations for execution.
**Lab Example:** Malicious npm package JavaScript payload
**Platforms:** Windows, macOS, Linux
**Data Sources:** Process, Script

**Detection Methods:**
- JavaScript runtime monitoring
- Script content analysis
- Process execution tracking
- Node.js application monitoring

**Mitigation Strategies:**
- Application controls and whitelisting
- Script execution policies
- Content Security Policy (CSP)
- Runtime application self-protection

### T1609 - Container Administration Command
**Used in:** Supply Chain Compromise, Supply Chain Container Escape

**Description:** Adversaries abuse container administration services for execution.
**Lab Example:** Docker/containerd command execution in compromised containers
**Platforms:** Containers
**Data Sources:** Container, Command

**Detection Methods:**
- Container runtime API monitoring
- Administrative command auditing
- Container behavior analysis
- Runtime security monitoring

**Mitigation Strategies:**
- Least privilege container policies
- Container admission controllers
- Runtime security tools
- Container image signing

### T1610 - Deploy Container
**Used in:** Supply Chain Container Escape, Supply Chain Compromise

**Description:** Adversaries deploy containers to facilitate execution or evade defenses.
**Lab Example:** Malicious container deployment in ECS/Kubernetes
**Platforms:** Containers
**Data Sources:** Container, Network Traffic

**Detection Methods:**
- Container deployment monitoring
- Unauthorized image detection
- Registry activity analysis
- Orchestrator audit logs

**Mitigation Strategies:**
- Image vulnerability scanning
- Container admission policies
- Network segmentation
- Registry access controls

### T1611 - Escape to Host
**Used in:** Supply Chain Container Escape

**Description:** Adversaries break out of containers to access the host.
**Lab Example:** Privileged container escape to host system
**Platforms:** Containers
**Data Sources:** Container, Process

**Detection Methods:**
- Container runtime monitoring
- Host filesystem access detection
- Privilege escalation detection
- System call monitoring

**Mitigation Strategies:**
- Container security policies
- Runtime protection
- Privileged container restrictions
- Host-based monitoring

---

## Persistence (TA0003)

### T1098.001 - Account Manipulation: Additional Cloud Credentials
**Used in:** Serverless Attack Chain, Multi-Cloud Federation

**Description:** Adversaries add credentials to cloud accounts for persistence.
**Lab Example:** Lambda IAM role credential manipulation
**Platforms:** IaaS, SaaS
**Data Sources:** User Account, Application Log

**Detection Methods:**
- Credential creation monitoring
- API key generation tracking
- IAM policy change detection
- Access key usage analysis

**Mitigation Strategies:**
- Credential lifecycle management
- Regular access reviews
- Automated credential rotation
- Least privilege policies

### T1525 - Implant Internal Image
**Used in:** Supply Chain Compromise

**Description:** Adversaries implant cloud/container images with malicious code.
**Lab Example:** Compromised npm package in container image
**Platforms:** IaaS, Containers
**Data Sources:** Image, Application Log

**Detection Methods:**
- Image vulnerability scanning
- Behavioral analysis of containers
- Registry integrity monitoring
- Software composition analysis

**Mitigation Strategies:**
- Image signing and verification
- Secure image registries
- Admission controllers
- Supply chain security

---

## Privilege Escalation (TA0004)

### T1548.005 - Abuse Elevation Control Mechanism: Temporary Elevated Cloud Access
**Used in:** AWS Privilege Escalation, Kubernetes RBAC Escalation

**Description:** Adversaries abuse cloud resource manager APIs for privilege escalation.
**Lab Example:** IAM role assumption, Kubernetes RBAC escalation
**Platforms:** IaaS
**Data Sources:** User Account, Application Log

**Detection Methods:**
- Role assumption monitoring
- Privilege escalation alerts
- API usage pattern analysis
- Elevation request auditing

**Mitigation Strategies:**
- Just-in-time access
- Approval workflows
- MFA for privilege escalation
- Regular privilege reviews

### T1134.001 - Access Token Manipulation: Token Impersonation/Theft
**Used in:** AWS Privilege Escalation, Kubernetes RBAC Escalation

**Description:** Adversaries impersonate user tokens to escalate privileges.
**Lab Example:** Service account token theft, STS token manipulation
**Platforms:** Windows, Linux, macOS, Containers
**Data Sources:** Process, User Account

**Detection Methods:**
- Token usage pattern monitoring
- Service account impersonation detection
- Authentication anomaly analysis
- Token lifetime tracking

**Mitigation Strategies:**
- Privileged access management
- Token rotation policies
- Service account monitoring
- Short-lived tokens

---

## Defense Evasion (TA0005)

### T1027 - Obfuscated Files or Information
**Used in:** Supply Chain Compromise

**Description:** Adversaries obfuscate files to evade detection.
**Lab Example:** Obfuscated malicious JavaScript in npm package
**Platforms:** Windows, Linux, macOS, Containers
**Data Sources:** File, Script

**Detection Methods:**
- File entropy analysis
- Behavioral detection systems
- Deobfuscation techniques
- Static analysis tools

**Mitigation Strategies:**
- Code signing requirements
- Application controls
- Endpoint detection and response
- Dynamic analysis

### T1562.008 - Impair Defenses: Disable Cloud Logs
**Used in:** Serverless Attack Chain

**Description:** Adversaries disable cloud logging to limit data collection.
**Lab Example:** SNS alerting disabled, CloudTrail logging disabled
**Platforms:** IaaS, SaaS
**Data Sources:** Cloud Service, Application Log

**Detection Methods:**
- Logging configuration monitoring
- Missing log event detection
- Configuration drift analysis
- Security control validation

**Mitigation Strategies:**
- Centralized logging architecture
- Immutable log storage
- Configuration management
- Security monitoring

---

## Credential Access (TA0006)

### T1552.001 - Unsecured Credentials: Credentials In Files
**Used in:** Secrets Sprawl Attack

**Description:** Adversaries search for credentials in files.
**Lab Example:** Hardcoded GitHub token in source code
**Platforms:** Windows, Linux, macOS, Containers
**Data Sources:** File, Command

**Detection Methods:**
- Source code secret scanning
- File access monitoring
- Credential pattern detection
- Repository monitoring

**Mitigation Strategies:**
- Secrets management systems
- Encrypted credential storage
- Access controls
- Regular secret rotation

### T1552.004 - Unsecured Credentials: Private Keys
**Used in:** Cross-Cloud Attack Chain, Secrets Sprawl Attack

**Description:** Adversaries search for private key certificate files.
**Lab Example:** Private keys in Terraform state, OIDC private keys
**Platforms:** Windows, Linux, macOS, Containers
**Data Sources:** File, Command

**Detection Methods:**
- Private key file monitoring
- Certificate enumeration detection
- Key usage analysis
- File integrity monitoring

**Mitigation Strategies:**
- Key management systems
- Hardware security modules
- Secure key storage
- Access logging

### T1552.007 - Unsecured Credentials: Container API
**Used in:** Supply Chain Compromise

**Description:** Adversaries gather credentials via container APIs.
**Lab Example:** ECS task metadata service credential access
**Platforms:** Containers
**Data Sources:** Container, Network Traffic

**Detection Methods:**
- Container API access monitoring
- Metadata service queries
- Unusual credential requests
- Container network analysis

**Mitigation Strategies:**
- Network policies
- Metadata service restrictions
- Least privilege containers
- Container security monitoring

### T1555 - Credentials from Password Stores
**Used in:** Supply Chain Compromise

**Description:** Adversaries access password storage locations.
**Lab Example:** Container environment variable secrets
**Platforms:** Windows, Linux, macOS
**Data Sources:** File, Process

**Detection Methods:**
- Password store access monitoring
- Process behavior analysis
- Credential enumeration detection
- System call tracking

**Mitigation Strategies:**
- Encrypted password stores
- Access controls
- Endpoint protection
- Secrets management

### T1550.001 - Use Alternate Authentication Material: Application Access Token
**Used in:** Multi-Cloud Federation Attack

**Description:** Adversaries use stolen application access tokens.
**Lab Example:** OIDC token abuse for cross-cloud authentication
**Platforms:** SaaS, Windows, Linux, macOS
**Data Sources:** Web Credential, Logon Session

**Detection Methods:**
- Token usage pattern analysis
- Token validation monitoring
- Authentication anomaly detection
- Cross-service access tracking

**Mitigation Strategies:**
- Token rotation policies
- Conditional access controls
- Behavioral analytics
- Token binding

---

## Discovery (TA0007)

### T1613 - Container and Resource Discovery
**Used in:** Kubernetes RBAC Escalation

**Description:** Adversaries discover containers and cluster resources.
**Lab Example:** Kubernetes API enumeration, cluster resource discovery
**Platforms:** Containers
**Data Sources:** Container, Network Traffic

**Detection Methods:**
- Cluster enumeration monitoring
- API server access logging
- Resource discovery tracking
- Unusual query patterns

**Mitigation Strategies:**
- Network segmentation
- RBAC controls
- API server monitoring
- Resource access policies

---

## Collection (TA0009)

### T1530 - Data from Cloud Storage Object
**Used in:** Serverless Attack Chain

**Description:** Adversaries access data from cloud storage.
**Lab Example:** S3 data lake access, DynamoDB table queries
**Platforms:** IaaS, SaaS
**Data Sources:** Cloud Storage, Network Traffic

**Detection Methods:**
- Cloud storage access monitoring
- Data access pattern analysis
- Unusual query detection
- Data classification tracking

**Mitigation Strategies:**
- Access controls and policies
- Data classification
- Encryption at rest
- Activity monitoring

---

## Exfiltration (TA0010)

### T1537 - Transfer Data to Cloud Account
**Used in:** Serverless Attack Chain

**Description:** Adversaries exfiltrate data to cloud accounts they control.
**Lab Example:** Customer data transferred to external S3 bucket
**Platforms:** IaaS, SaaS
**Data Sources:** Cloud Storage, Network Traffic

**Detection Methods:**
- Data transfer monitoring
- New cloud account detection
- Unusual upload patterns
- Data loss prevention

**Mitigation Strategies:**
- Data loss prevention tools
- Network monitoring
- Access controls
- Data classification

---

## Supply Chain (Special Category)

### T1195.002 - Supply Chain Compromise: Compromise Software Supply Chain
**Used in:** Cross-Cloud Attack Chain, Supply Chain Container Escape, Supply Chain Compromise

**Description:** Adversaries manipulate software prior to receipt.
**Lab Example:** Compromised npm packages, malicious container images
**Platforms:** Windows, Linux, macOS
**Data Sources:** File, Network Traffic

**Detection Methods:**
- Software composition analysis
- Build pipeline monitoring
- Integrity checking
- Dependency scanning

**Mitigation Strategies:**
- Secure development practices
- Code signing
- Supply chain security
- Vendor risk management

---

## Graph Queries for MITRE Analysis

### All Techniques with Usage Statistics
```cypher
MATCH (technique:MITRETechnique)
OPTIONAL MATCH (technique)<-[:USES_TECHNIQUE]-(entity)
OPTIONAL MATCH (technique)-[:ENABLES_TACTIC]->(tactic:MITRETactic)
RETURN 
    technique.technique_id as TechniqueID,
    technique.technique_name as TechniqueName,
    tactic.tactic_name as Tactic,
    count(entity) as EntitiesUsingTechnique,
    collect(DISTINCT labels(entity)[0]) as EntityTypes
ORDER BY EntitiesUsingTechnique DESC, TechniqueID
```

### Tactics Coverage Analysis
```cypher
MATCH (tactic:MITRETactic)
OPTIONAL MATCH (tactic)<-[:ENABLES_TACTIC]-(technique:MITRETechnique)
OPTIONAL MATCH (technique)<-[:USES_TECHNIQUE]-(entity)
RETURN 
    tactic.tactic_id as TacticID,
    tactic.tactic_name as TacticName,
    count(DISTINCT technique) as TechniquesInTactic,
    count(entity) as EntitiesUsingTactic
ORDER BY TacticID
```

### Cross-Scenario Technique Usage
```cypher
MATCH (technique:MITRETechnique)<-[:USES_TECHNIQUE]-(entity)
WITH technique, collect(DISTINCT entity.phase) as phases
WHERE size(phases) > 1
RETURN 
    technique.technique_id as TechniqueID,
    technique.technique_name as TechniqueName,
    phases as UsedInPhases,
    size(phases) as PhaseCount
ORDER BY PhaseCount DESC
```

### Detection Coverage Analysis
```cypher
MATCH (technique:MITRETechnique)
RETURN 
    technique.technique_id as TechniqueID,
    technique.technique_name as TechniqueName,
    CASE WHEN technique.detection IS NOT NULL THEN 'Yes' ELSE 'No' END as HasDetection,
    CASE WHEN technique.mitigation IS NOT NULL THEN 'Yes' ELSE 'No' END as HasMitigation
ORDER BY TechniqueID
```

---

## MITRE Navigator Integration

### Generating ATT&CK Navigator JSON
The lab can export MITRE ATT&CK Navigator compatible JSON:

```cypher
MATCH (technique:MITRETechnique)<-[:USES_TECHNIQUE]-(entity)
WITH technique, count(entity) as usage_count
RETURN {
    "technique_id": technique.technique_id,
    "score": usage_count,
    "color": CASE 
        WHEN usage_count > 3 THEN "#ff0000"
        WHEN usage_count > 1 THEN "#ffaa00" 
        ELSE "#00ff00"
    END,
    "comment": technique.technique_name + " - Used by " + usage_count + " entities"
} as navigator_entry
```

### Heat Map Generation
Visualize technique usage across the lab:

```cypher
MATCH (technique:MITReTechnique)-[:ENABLES_TACTIC]->(tactic:MITReTactic)
OPTIONAL MATCH (technique)<-[:USES_TECHNIQUE]-(entity)
RETURN 
    tactic.tactic_name as Tactic,
    technique.technique_id as TechniqueID,
    count(entity) as HeatMapValue
ORDER BY Tactic, TechniqueID
```

---

## Integration Benefits

### Security Education
- **Realistic Mappings**: Every technique maps to real attack scenarios
- **Complete Coverage**: Detection and mitigation for all techniques
- **Hands-on Learning**: Interactive queries demonstrate technique usage

### Threat Modeling
- **Gap Analysis**: Identify detection and mitigation gaps
- **Risk Assessment**: Quantify technique usage and impact
- **Defense Planning**: Prioritize security controls based on technique frequency

### Compliance and Reporting
- **Framework Alignment**: Map security controls to MITRE techniques
- **Coverage Reports**: Generate compliance documentation
- **Maturity Assessment**: Measure security program effectiveness

### Research and Development
- **Technique Analysis**: Study attack technique relationships
- **Pattern Recognition**: Identify common technique combinations
- **Defense Innovation**: Develop new detection and mitigation strategies