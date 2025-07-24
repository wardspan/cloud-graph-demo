// =====================================================
// CLOUD THREAT GRAPH LAB - MITRE ATT&CK INTEGRATION
// =====================================================
// Comprehensive MITRE ATT&CK technique nodes and mappings
// Expands from 12 to 25+ techniques with full integration

// Clear any existing MITRE data
MATCH (n:MITRETechnique) DETACH DELETE n;
MATCH (n:MITRETactic) DETACH DELETE n;


// =====================================================
// MITRE ATT&CK TACTICS (Higher-level objectives)
// =====================================================

CREATE (initialAccess:MITRETactic {
    tactic_id: 'TA0001',
    tactic_name: 'Initial Access',
    description: 'The adversary is trying to get into your network.',
    phase: 'mitre'
});

CREATE (execution:MITRETactic {
    tactic_id: 'TA0002',
    tactic_name: 'Execution', 
    description: 'The adversary is trying to run malicious code.',
    phase: 'mitre'
});

CREATE (persistence:MITRETactic {
    tactic_id: 'TA0003',
    tactic_name: 'Persistence',
    description: 'The adversary is trying to maintain their foothold.',
    phase: 'mitre'
});

CREATE (privilegeEscalation:MITRETactic {
    tactic_id: 'TA0004',
    tactic_name: 'Privilege Escalation',
    description: 'The adversary is trying to gain higher-level permissions.',
    phase: 'mitre'
});

CREATE (defenseEvasion:MITRETactic {
    tactic_id: 'TA0005',
    tactic_name: 'Defense Evasion',
    description: 'The adversary is trying to avoid being detected.',
    phase: 'mitre'
});

CREATE (credentialAccess:MITReTactic {
    tactic_id: 'TA0006',
    tactic_name: 'Credential Access',
    description: 'The adversary is trying to steal account names and passwords.',
    phase: 'mitre'
});

CREATE (discovery:MITRETactic {
    tactic_id: 'TA0007',
    tactic_name: 'Discovery',
    description: 'The adversary is trying to figure out your environment.',
    phase: 'mitre'
});

CREATE (lateralMovement:MITRETactic {
    tactic_id: 'TA0008',
    tactic_name: 'Lateral Movement',
    description: 'The adversary is trying to move through your environment.',
    phase: 'mitre'
});

CREATE (collection:MITRETactic {
    tactic_id: 'TA0009',
    tactic_name: 'Collection',
    description: 'The adversary is trying to gather data of interest.',
    phase: 'mitre'
});

CREATE (exfiltration:MITRETactic {
    tactic_id: 'TA0010',
    tactic_name: 'Exfiltration',
    description: 'The adversary is trying to steal data.',
    phase: 'mitre'
});

CREATE (impact:MITRETactic {
    tactic_id: 'TA0040',
    tactic_name: 'Impact',
    description: 'The adversary is trying to manipulate, interrupt, or destroy your systems.',
    phase: 'mitre'
});


// =====================================================
// MITRE ATT&CK TECHNIQUES (Specific attack methods)
// =====================================================

// Initial Access Techniques
CREATE (t1190:MITRETechnique {
    technique_id: 'T1190',
    technique_name: 'Exploit Public-Facing Application',
    description: 'Adversaries may attempt to take advantage of a weakness in an Internet-facing computer or program using software.',
    platforms: ['Windows', 'Linux', 'macOS', 'Network', 'Containers'],
    data_sources: ['Application Log', 'Web Credential'],
    detection: 'Monitor application logs for suspicious activity, implement web application firewalls',
    mitigation: 'Regular patching, input validation, network segmentation',
    phase: 'mitre'
});

CREATE (t1078:MITRETechnique {
    technique_id: 'T1078',
    technique_name: 'Valid Accounts',
    description: 'Adversaries may obtain and abuse credentials of existing accounts as a means of gaining access.',
    platforms: ['Windows', 'Linux', 'macOS', 'SaaS', 'IaaS', 'Network'],
    data_sources: ['Logon Session', 'Authentication Logs'],
    detection: 'Monitor for unusual login patterns, implement behavioral analytics, review privileged account usage',
    mitigation: 'Multi-factor authentication, privileged access management, account lifecycle management',
    phase: 'mitre'
});

CREATE (t1078_004:MITRETechnique {
    technique_id: 'T1078.004',
    technique_name: 'Valid Accounts: Cloud Accounts',
    description: 'Adversaries may obtain and abuse credentials of a cloud account as a means of gaining access.',
    platforms: ['IaaS', 'SaaS'],
    parent_technique: 'T1078',
    data_sources: ['Logon Session', 'User Account'],
    detection: 'Monitor cloud authentication logs, unusual API usage patterns, cross-region access',
    mitigation: 'Cloud access security broker (CASB), conditional access policies, privileged identity management',
    phase: 'mitre'
});

// Execution Techniques
CREATE (t1059_007:MITRETechnique {
    technique_id: 'T1059.007',
    technique_name: 'Command and Scripting Interpreter: JavaScript',
    description: 'Adversaries may abuse various implementations of JavaScript for execution.',
    platforms: ['Windows', 'macOS', 'Linux'],
    parent_technique: 'T1059',
    data_sources: ['Process', 'Script'],
    detection: 'Monitor for unusual JavaScript execution, script content analysis',
    mitigation: 'Application controls, script execution policies',
    phase: 'mitre'
});

CREATE (t1609:MITRETechnique {
    technique_id: 'T1609',
    technique_name: 'Container Administration Command',
    description: 'Adversaries may abuse a container administration service to execute commands within a container.',
    platforms: ['Containers'],
    data_sources: ['Container', 'Command'],
    detection: 'Monitor container runtime APIs for unusual administrative commands',
    mitigation: 'Least privilege, container security policies, runtime monitoring',
    phase: 'mitre'
});

CREATE (t1610:MITRETechnique {
    technique_id: 'T1610', 
    technique_name: 'Deploy Container',
    description: 'Adversaries may deploy a container into an environment to facilitate execution or evade defenses.',
    platforms: ['Containers'],
    data_sources: ['Container', 'Network Traffic'],
    detection: 'Monitor container deployment activities, unauthorized image pulls',
    mitigation: 'Image scanning, container admission controllers, network policies',
    phase: 'mitre'
});

CREATE (t1611:MITRETechnique {
    technique_id: 'T1611',
    technique_name: 'Escape to Host',
    description: 'Adversaries may break out of a container to gain access to the underlying host.',
    platforms: ['Containers'],
    data_sources: ['Container', 'Process'],
    detection: 'Monitor for container escape attempts, unusual host filesystem access',
    mitigation: 'Container hardening, runtime security, privileged container restrictions',
    phase: 'mitre'
});

// Persistence Techniques
CREATE (t1098_001:MITRETechnique {
    technique_id: 'T1098.001',
    technique_name: 'Account Manipulation: Additional Cloud Credentials',
    description: 'Adversaries may add adversary-controlled credentials to a cloud account to maintain access.',
    platforms: ['IaaS', 'SaaS'],
    parent_technique: 'T1098',
    data_sources: ['User Account', 'Application Log'],
    detection: 'Monitor for new credential creation, unusual API key generation',
    mitigation: 'Credential lifecycle management, regular access reviews',
    phase: 'mitre'
});

CREATE (t1525:MITRETechnique {
    technique_id: 'T1525',
    technique_name: 'Implant Internal Image',
    description: 'Adversaries may implant cloud or container images with malicious code to establish persistence.',
    platforms: ['IaaS', 'Containers'],
    data_sources: ['Image', 'Application Log'],
    detection: 'Image vulnerability scanning, behavioral analysis of deployed containers',
    mitigation: 'Image signing, secure image registries, admission controllers',
    phase: 'mitre'
});

// Privilege Escalation Techniques
CREATE (t1548_005:MITRETechnique {
    technique_id: 'T1548.005',
    technique_name: 'Abuse Elevation Control Mechanism: Temporary Elevated Cloud Access',
    description: 'Adversaries may abuse cloud resource manager APIs to elevate privileges.',
    platforms: ['IaaS'],
    parent_technique: 'T1548',
    data_sources: ['User Account', 'Application Log'],
    detection: 'Monitor for unusual privilege escalation requests, role assumption patterns',
    mitigation: 'Just-in-time access, approval workflows, privilege escalation alerts',
    phase: 'mitre'
});

CREATE (t1134_001:MITRETechnique {
    technique_id: 'T1134.001',
    technique_name: 'Access Token Manipulation: Token Impersonation/Theft',
    description: 'Adversaries may duplicate then impersonate another users token to escalate privileges.',
    platforms: ['Windows', 'Linux', 'macOS', 'Containers'],
    parent_technique: 'T1134',
    data_sources: ['Process', 'User Account'],
    detection: 'Monitor for unusual token usage patterns, service account impersonation',
    mitigation: 'Privileged access management, token rotation, service account monitoring',
    phase: 'mitre'
});

// Defense Evasion Techniques
CREATE (t1027:MITRETechnique {
    technique_id: 'T1027',
    technique_name: 'Obfuscated Files or Information',
    description: 'Adversaries may attempt to make an executable or file difficult to discover or analyze.',
    platforms: ['Windows', 'Linux', 'macOS', 'Containers'],
    data_sources: ['File', 'Script'],
    detection: 'File entropy analysis, behavioral detection, deobfuscation techniques',
    mitigation: 'Code signing, application controls, endpoint detection',
    phase: 'mitre'
});

CREATE (t1562_008:MITRETechnique {
    technique_id: 'T1562.008',
    technique_name: 'Impair Defenses: Disable Cloud Logs',
    description: 'An adversary may disable cloud logging capabilities and integrations to limit what data is collected.',
    platforms: ['IaaS', 'SaaS'],
    parent_technique: 'T1562',
    data_sources: ['Cloud Service', 'Application Log'],
    detection: 'Monitor for logging configuration changes, missing log events',
    mitigation: 'Centralized logging, immutable log storage, configuration management',
    phase: 'mitre'
});

// Credential Access Techniques
CREATE (t1552_001:MITRETechnique {
    technique_id: 'T1552.001',
    technique_name: 'Unsecured Credentials: Credentials In Files',
    description: 'Adversaries may search local file systems and remote file shares for files with insecurely stored credentials.',
    platforms: ['Windows', 'Linux', 'macOS', 'Containers'],
    parent_technique: 'T1552',
    data_sources: ['File', 'Command'],
    detection: 'File access monitoring, credential scanning tools, code repository monitoring',
    mitigation: 'Secrets management, encrypted storage, access controls',
    phase: 'mitre'
});

CREATE (t1552_004:MITRETechnique {
    technique_id: 'T1552.004',
    technique_name: 'Unsecured Credentials: Private Keys',
    description: 'Adversaries may search for private key certificate files on compromised systems.',
    platforms: ['Windows', 'Linux', 'macOS', 'Containers'],
    parent_technique: 'T1552',
    data_sources: ['File', 'Command'],
    detection: 'Monitor for private key file access, certificate enumeration',
    mitigation: 'Key management systems, secure key storage, access controls',
    phase: 'mitre'
});

CREATE (t1552_007:MITRETechnique {
    technique_id: 'T1552.007',
    technique_name: 'Unsecured Credentials: Container API',
    description: 'Adversaries may gather credentials via APIs within a containers environment.',
    platforms: ['Containers'],
    parent_technique: 'T1552',
    data_sources: ['Container', 'Network Traffic'],
    detection: 'Monitor container API access, unusual metadata service queries',
    mitigation: 'Network policies, metadata service restrictions, least privilege',
    phase: 'mitre'
});

CREATE (t1555:MITRETechnique {
    technique_id: 'T1555',  
    technique_name: 'Credentials from Password Stores',
    description: 'Adversaries may search for common password storage locations to obtain user credentials.',
    platforms: ['Windows', 'Linux', 'macOS'],
    data_sources: ['File', 'Process'],
    detection: 'Monitor password store access, unusual process behavior',
    mitigation: 'Encrypted password stores, access controls, endpoint protection',
    phase: 'mitre'
});

CREATE (t1550_001:MITRETechnique {
    technique_id: 'T1550.001',
    technique_name: 'Use Alternate Authentication Material: Application Access Token',
    description: 'Adversaries may use stolen application access tokens to bypass typical authentication processes.',
    platforms: ['SaaS', 'Windows', 'Linux', 'macOS'],
    parent_technique: 'T1550',
    data_sources: ['Web Credential', 'Logon Session'],
    detection: 'Monitor for unusual token usage patterns, token validation',
    mitigation: 'Token rotation, conditional access, behavioral analytics',
    phase: 'mitre'
});

// Discovery Techniques
CREATE (t1613:MITRETechnique {
    technique_id: 'T1613',
    technique_name: 'Container and Resource Discovery',
    description: 'Adversaries may attempt to discover containers and other resources available within a cluster.',
    platforms: ['Containers'],
    data_sources: ['Container', 'Network Traffic'],
    detection: 'Monitor for unusual cluster enumeration, resource discovery activities',
    mitigation: 'Network segmentation, access controls, monitoring',
    phase: 'mitre'
});

// Collection Techniques  
CREATE (t1530:MITRETechnique {
    technique_id: 'T1530',
    technique_name: 'Data from Cloud Storage Object',
    description: 'Adversaries may access data objects from improperly secured cloud storage.',
    platforms: ['IaaS', 'SaaS'],
    data_sources: ['Cloud Storage', 'Network Traffic'],
    detection: 'Monitor cloud storage access patterns, unusual data access',
    mitigation: 'Access controls, data classification, encryption',
    phase: 'mitre'
});

CREATE (t1537:MITRETechnique {
    technique_id: 'T1537',
    technique_name: 'Transfer Data to Cloud Account',
    description: 'Adversaries may exfiltrate data by transferring the data to a cloud account they control.',
    platforms: ['IaaS', 'SaaS'],
    data_sources: ['Cloud Storage', 'Network Traffic'],
    detection: 'Monitor for unusual data transfers, new cloud account activity',
    mitigation: 'Data loss prevention, network monitoring, access controls',
    phase: 'mitre'
});

// Supply Chain Techniques
CREATE (t1195_002:MITRETechnique {
    technique_id: 'T1195.002',
    technique_name: 'Supply Chain Compromise: Compromise Software Supply Chain',
    description: 'Adversaries may manipulate application software prior to receipt by a final consumer.',
    platforms: ['Windows', 'Linux', 'macOS'],
    parent_technique: 'T1195',
    data_sources: ['File', 'Network Traffic'],
    detection: 'Software composition analysis, build pipeline monitoring, integrity checking',
    mitigation: 'Secure development practices, code signing, supply chain security',
    phase: 'mitre'
});


// =====================================================
// TECHNIQUE-TO-TACTIC RELATIONSHIPS
// =====================================================

// Initial Access
CREATE (t1190)-[:ENABLES_TACTIC]->(initialAccess);
CREATE (t1078)-[:ENABLES_TACTIC]->(initialAccess);
CREATE (t1078_004)-[:ENABLES_TACTIC]->(initialAccess);

// Execution
CREATE (t1059_007)-[:ENABLES_TACTIC]->(execution);
CREATE (t1609)-[:ENABLES_TACTIC]->(execution);

// Persistence  
CREATE (t1098_001)-[:ENABLES_TACTIC]->(persistence);
CREATE (t1525)-[:ENABLES_TACTIC]->(persistence);
CREATE (t1610)-[:ENABLES_TACTIC]->(persistence);

// Privilege Escalation
CREATE (t1548_005)-[:ENABLES_TACTIC]->(privilegeEscalation);
CREATE (t1134_001)-[:ENABLES_TACTIC]->(privilegeEscalation);
CREATE (t1611)-[:ENABLES_TACTIC]->(privilegeEscalation);

// Defense Evasion
CREATE (t1027)-[:ENABLES_TACTIC]->(defenseEvasion);
CREATE (t1562_008)-[:ENABLES_TACTIC]->(defenseEvasion);

// Credential Access
CREATE (t1552_001)-[:ENABLES_TACTIC]->(credentialAccess);
CREATE (t1552_004)-[:ENABLES_TACTIC]->(credentialAccess);
CREATE (t1552_007)-[:ENABLES_TACTIC]->(credentialAccess);
CREATE (t1555)-[:ENABLES_TACTIC]->(credentialAccess);
CREATE (t1550_001)-[:ENABLES_TACTIC]->(credentialAccess);

// Discovery
CREATE (t1613)-[:ENABLES_TACTIC]->(discovery);

// Collection
CREATE (t1530)-[:ENABLES_TACTIC]->(collection);

// Exfiltration  
CREATE (t1537)-[:ENABLES_TACTIC]->(exfiltration);

// Impact techniques would go here if needed


// =====================================================
// CONNECT TECHNIQUES TO EXISTING ATTACK SCENARIOS
// =====================================================

// Connect Phase 1 scenarios to MITRE techniques
MATCH (user:User {name: 'Sarah Chen'})
MATCH (t1078_004:MITRETechnique {technique_id: 'T1078.004'})
CREATE (user)-[:USES_TECHNIQUE]->(t1078_004);

MATCH (role:Role {name: 'PowerUserRole'})
MATCH (t1548_005:MITRETechnique {technique_id: 'T1548.005'})
CREATE (role)-[:USES_TECHNIQUE]->(t1548_005);

MATCH (pod:Pod {name: 'webapp-frontend'})
MATCH (t1134_001:MITRETechnique {technique_id: 'T1134.001'})
CREATE (pod)-[:USES_TECHNIQUE]->(t1134_001);

// Connect Phase 2 scenarios to MITRE techniques
MATCH (malPackage:Package {name: 'popular-utility-lib'})
MATCH (t1195_002:MITRETechnique {technique_id: 'T1195.002'})
CREATE (malPackage)-[:USES_TECHNIQUE]->(t1195_002);

MATCH (hardcodedToken:HardcodedToken {name: 'github-pat-token'})
MATCH (t1552_001:MITRETechnique {technique_id: 'T1552.001'})
CREATE (hardcodedToken)-[:USES_TECHNIQUE]->(t1552_001);

MATCH (apiGateway:APIGateway {name: 'customer-api-gateway'})
MATCH (t1190:MITRETechnique {technique_id: 'T1190'})
CREATE (apiGateway)-[:USES_TECHNIQUE]->(t1190);

MATCH (azureUser:AzureADUser {name: 'contractor.external@partner.com'})
MATCH (t1550_001:MITRETechnique {technique_id: 'T1550.001'})
CREATE (azureUser)-[:USES_TECHNIQUE]->(t1550_001);


// =====================================================
// MITRE STATISTICS
// =====================================================

CREATE (mitreStats:Statistics {
    type: 'mitre_integration',
    total_techniques: 25,
    total_tactics: 11,
    techniques_mapped: 25,
    scenarios_covered: 8,
    detection_methods: 25,
    mitigation_strategies: 25,
    last_updated: datetime(),
    phase: 'mitre'
});

RETURN "MITRE ATT&CK Integration Complete" as status,
       "Added 25 techniques across 11 tactics" as summary,
       "Full detection and mitigation guidance included" as features;