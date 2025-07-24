// =============================================================================
// CLOUD THREAT GRAPH LAB - PHASE 3: CARTOGRAPHY INTEGRATION SCENARIOS
// =============================================================================
//
// This file creates the foundation for asset discovery scenarios.
// Simplified version to avoid Cypher syntax issues.
//

// Clear any existing discovery-related constraints
DROP CONSTRAINT asset_discovery_unique IF EXISTS;

// =============================================================================
// SCENARIO 9: REAL-WORLD ASSET DISCOVERY ATTACK PATH
// =============================================================================
//
// This scenario demonstrates how attackers leverage cloud service discovery
// to identify overprivileged resources and exploit them for privilege escalation.
//

// Create mock discovered AWS infrastructure
CREATE (discoveredVPC:AWSService {
    name: 'prod-vpc-discovered',
    type: 'VPC',
    cloud_provider: 'AWS',
    discovered_via_cartography: true,
    discovery_time: datetime('2024-01-15T10:30:00Z'),
    security_risk: 'MEDIUM',
    risk_reason: 'Overly permissive security groups discovered'
});

CREATE (discoveredEC2:AWSService {
    name: 'web-server-discovered',
    type: 'EC2',
    cloud_provider: 'AWS',
    discovered_via_cartography: true,
    discovery_time: datetime('2024-01-15T10:31:00Z'),
    contains_pii: true,
    security_risk: 'HIGH',
    risk_reason: 'Instance has admin IAM role attached'
});

CREATE (discoveredRole:AWSRole {
    name: 'EC2AdminRole-discovered',
    cloud_provider: 'AWS',
    discovered_via_cartography: true,
    discovery_time: datetime('2024-01-15T10:32:00Z'),
    permissions: ['ec2:*', 's3:*', 'iam:*'],
    security_risk: 'CRITICAL',
    risk_reason: 'Overprivileged role with admin permissions'
});

CREATE (discoveredS3:AWSService {
    name: 'customer-data-discovered',
    type: 'S3Bucket',
    cloud_provider: 'AWS',
    discovered_via_cartography: true,
    discovery_time: datetime('2024-01-15T10:33:00Z'),
    contains_pii: true,
    public_access_blocked: false,
    security_risk: 'CRITICAL',
    risk_reason: 'Bucket contains PII and has public access'
});

// Create attack path relationships
CREATE (discoveredEC2)-[:ASSUMES_ROLE]->(discoveredRole);
CREATE (discoveredRole)-[:CAN_ACCESS]->(discoveredS3);
CREATE (discoveredVPC)-[:CONTAINS]->(discoveredEC2);

// =============================================================================
// SCENARIO 10: CROSS-CLOUD INFRASTRUCTURE ATTACK VIA ASSET DISCOVERY
// =============================================================================
//
// This scenario shows how automated discovery reveals hidden cross-cloud
// trust relationships that enable multi-cloud attacks.
//

// Create Azure discovered infrastructure
CREATE (discoveredAzureAD:AzureUser {
    name: 'contractor-discovered',
    cloud_provider: 'Azure',
    discovered_via_cartography: true,
    discovery_time: datetime('2024-01-15T11:00:00Z'),
    user_type: 'Guest',
    mfa_enabled: false,
    security_risk: 'HIGH',
    risk_reason: 'External contractor without MFA'
});

CREATE (discoveredFederation:TrustRelationship {
    name: 'azure-aws-federation',
    source_cloud: 'Azure',
    target_cloud: 'AWS',
    discovered_via_cartography: true,
    discovery_time: datetime('2024-01-15T11:01:00Z'),
    trust_type: 'OIDC_Federation',
    security_risk: 'MEDIUM',
    risk_reason: 'Cross-cloud trust relationship'
});

CREATE (discoveredAWSRole:AWSRole {
    name: 'FederatedRole-discovered',
    cloud_provider: 'AWS',
    discovered_via_cartography: true,
    discovery_time: datetime('2024-01-15T11:02:00Z'),
    permissions: ['s3:GetObject', 'ec2:DescribeInstances'],
    federated_access: true,
    security_risk: 'MEDIUM',
    risk_reason: 'Role accessible via federation'
});

// Create cross-cloud attack path
CREATE (discoveredAzureAD)-[:FEDERATED_TRUST]->(discoveredFederation);
CREATE (discoveredFederation)-[:GRANTS_ACCESS]->(discoveredAWSRole);
CREATE (discoveredAWSRole)-[:CAN_ACCESS]->(discoveredS3);

// =============================================================================
// PHASE 3 COMPLETION MESSAGE
// =============================================================================

CREATE (phase3Complete:StatusMessage {
    phase: 'Phase 3: Cartography Integration',
    status: 'Complete',
    message: 'Asset discovery scenarios ready - 2 new discovery-based attack paths created',
    features: [
        'Real-world asset discovery attack simulation',
        'Cross-cloud infrastructure discovery paths', 
        'Mock discovered assets with security risks',
        'Discovery timeline and risk assessment'
    ],
    scenarios_added: ['Real-World Asset Discovery Attack Path', 'Cross-Cloud Infrastructure Attack via Asset Discovery'],
    mitre_techniques: ['T1526', 'T1087', 'T1069', 'T1538', 'T1550.001', 'T1199']
});

RETURN 'Phase 3: Cartography Integration & Asset Discovery - Complete!' as status,
       'Added 2 discovery-based attack scenarios with mock infrastructure' as summary,
       'Discovery simulation ready for dashboard integration' as next_steps;