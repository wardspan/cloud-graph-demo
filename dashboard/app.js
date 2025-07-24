// Cloud Threat Graph Lab Dashboard
class ThreatGraphDashboard {
    constructor() {
        this.neo4jUrl = 'bolt://localhost:7687';
        this.neo4jUser = 'neo4j';
        this.neo4jPassword = 'cloudsecurity';
        this.init();
    }

    init() {
        this.loadStatistics();
        this.setupEventListeners();
        this.displayScenarios();
    }

    setupEventListeners() {
        // Query buttons
        document.getElementById('queryAllNodes').addEventListener('click', () => {
            this.runQuery('MATCH (n) RETURN labels(n)[0] as NodeType, count(n) as Count ORDER BY Count DESC');
        });

        document.getElementById('queryAttackPaths').addEventListener('click', () => {
            this.runQuery(`
                MATCH path = (start:User)-[*1..4]->(target:Service)
                WHERE start.access_level = 'developer' AND target.contains_pii = true
                RETURN 
                    start.name as StartUser,
                    target.name as TargetService,
                    length(path) as PathLength,
                    [node in nodes(path) | labels(node)[0]] as NodeTypes
                ORDER BY PathLength
                LIMIT 5
            `);
        });

        document.getElementById('queryPrivEsc').addEventListener('click', () => {
            this.runQuery(`
                MATCH (user:User)-[:ASSUMES_ROLE|CAN_ESCALATE_TO*1..3]->(role:Role)
                WHERE user.access_level = 'developer' 
                AND (role.permissions IS NOT NULL OR role.name CONTAINS 'admin')
                RETURN 
                    user.name as User,
                    user.access_level as StartLevel,
                    role.name as TargetRole,
                    role.permissions as Permissions
                ORDER BY User
            `);
        });

        document.getElementById('queryK8sRBAC').addEventListener('click', () => {
            this.runQuery(`
                MATCH (pod:Pod)-[:MOUNTS_SA]->(sa:ServiceAccount)
                MATCH (sa)-[:BOUND_TO]->(binding:RoleBinding)-[:GRANTS_ROLE]->(role:Role)
                RETURN 
                    pod.name as Pod,
                    pod.namespace as Namespace,
                    sa.name as ServiceAccount,
                    role.name as Role,
                    role.rules as Permissions
                ORDER BY Namespace, Pod
            `);
        });

        document.getElementById('queryMitre').addEventListener('click', () => {
            this.runQuery(`
                MATCH (n)
                WHERE n.mitre_techniques IS NOT NULL
                UNWIND n.mitre_techniques as technique
                RETURN 
                    technique as MitreTechnique,
                    count(n) as NodesUsingTechnique,
                    collect(DISTINCT labels(n)[0]) as NodeTypes
                ORDER BY NodesUsingTechnique DESC
            `);
        });

        document.getElementById('querySupplyChain').addEventListener('click', () => {
            this.runQuery(`
                MATCH path = (pkg:Package)-[*1..5]->(host:Host)
                WHERE pkg.compromised = true
                RETURN 
                    pkg.name as CompromisedPackage,
                    pkg.version as Version,
                    host.name as TargetHost,
                    length(path) as AttackSteps,
                    [rel in relationships(path) | type(rel)] as AttackPath
                ORDER BY AttackSteps
            `);
        });
    }

    displayScenarios() {
        const scenarios = [
            {
                name: "AWS Privilege Escalation",
                description: "Developer user escalates to admin via role assumption",
                severity: "HIGH",
                techniques: ["T1078.004", "T1548.005", "T1134.001"]
            },
            {
                name: "Cross-Cloud Attack Chain", 
                description: "Azure AD user compromises AWS resources via CI/CD",
                severity: "CRITICAL",
                techniques: ["T1078.004", "T1195.002", "T1552.004"]
            },
            {
                name: "Kubernetes RBAC Escalation",
                description: "Pod service account escalates to cluster admin", 
                severity: "HIGH",
                techniques: ["T1134.001", "T1548.005", "T1613"]
            },
            {
                name: "Supply Chain Container Escape",
                description: "Compromised package leads to host compromise",
                severity: "CRITICAL", 
                techniques: ["T1195.002", "T1610", "T1611"]
            }
        ];

        const scenarioList = document.getElementById('scenarioList');
        scenarioList.innerHTML = scenarios.map(scenario => `
            <li class="scenario-item" onclick="window.threatDashboard.exploreScenario('${scenario.name}')">
                <div class="scenario-name">${scenario.name}</div>
                <div class="scenario-description">${scenario.description}</div>
                <div class="severity ${scenario.severity}">${scenario.severity}</div>
                <div style="margin-top: 8px; font-size: 0.8em; color: #6c757d;">
                    MITRE: ${scenario.techniques.join(', ')}
                </div>
            </li>
        `).join('');
    }

    exploreScenario(scenarioName) {
        console.log('exploreScenario called with:', scenarioName);
        
        // Update the overview panel with scenario information
        this.updateOverviewPanel(scenarioName);
        
        // Show loading state immediately
        const resultsDiv = document.getElementById('queryResults');
        resultsDiv.innerHTML = `<div class="loading">Loading scenario: ${scenarioName}...</div>`;
        
        // Scroll to results section
        resultsDiv.scrollIntoView({ behavior: 'smooth' });
        
        const queries = {
            'AWS Privilege Escalation': {
                query: `// Show direct access paths from developers to sensitive services
MATCH path = (user:User)-[*1..3]->(service:Service)
WHERE user.access_level = 'developer' 
  AND (service.contains_pii = true OR service.type = 'S3Bucket')
RETURN 
    user.name as StartUser,
    user.email as Email,
    user.access_level as StartLevel,
    service.name as TargetService,
    service.type as ServiceType,
    service.contains_pii as ContainsPII,
    length(path) as EscalationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as AttackPath,
    [rel in relationships(path) | type(rel)] as Relations
ORDER BY EscalationSteps
LIMIT 10`,
                description: "This query finds attack paths from developer users to sensitive AWS services containing PII data.",
                expectedResults: "Shows how 'Sarah Chen' can access sensitive S3 buckets through various paths including direct access and role assumptions."
            },
            'Cross-Cloud Attack Chain': {
                query: `// Trace cross-cloud attack paths from Azure users to AWS services
MATCH path = (azure:User)-[*1..4]->(aws:Service)
WHERE azure.tenant_id IS NOT NULL 
  AND (aws.type = 'S3Bucket' OR labels(aws) CONTAINS 'AWSService')
RETURN 
    azure.name as AzureUser,
    azure.email as Email,
    azure.tenant_id as TenantID,
    aws.name as AWSTarget,
    aws.type as ServiceType,
    length(path) as PathLength,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as AttackChain,
    [rel in relationships(path) | type(rel)] as AttackMethods
ORDER BY PathLength
LIMIT 10`,
                description: "This query traces cross-cloud attack paths from Azure AD users to AWS services.",
                expectedResults: "Shows how 'Emma Watson' can access AWS S3 through GitHub Actions CI/CD pipeline paths."
            },
            'Kubernetes RBAC Escalation': {
                query: `// Analyze Kubernetes RBAC configurations and permissions
MATCH path = (pod:Pod)-[*1..3]->(role:Role)
WHERE pod.namespace IS NOT NULL
RETURN 
    pod.name as Pod,
    pod.namespace as PodNamespace,
    role.name as GrantedRole,
    role.type as RoleType,
    role.rules as Permissions,
    length(path) as EscalationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as EscalationPath,
    CASE 
        WHEN role.name CONTAINS 'admin' OR role.name = 'cluster-admin' THEN 'HIGH RISK'
        WHEN role.rules CONTAINS '*' THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END as RiskLevel
ORDER BY RiskLevel DESC, EscalationSteps
LIMIT 10`,
                description: "This query analyzes Kubernetes RBAC configurations and potential privilege escalation paths.",
                expectedResults: "Shows pod service account bindings and identifies potential escalation to cluster-admin privileges."
            },
            'Supply Chain Container Escape': {
                query: `// Trace supply chain attack paths from packages to hosts
MATCH path = (pkg:Package)-[*1..4]->(host:Host)
WHERE pkg.compromised = true
RETURN 
    pkg.name as CompromisedPackage,
    pkg.version as Version,
    pkg.payload_type as PayloadType,
    pkg.registry as Registry,
    host.name as CompromisedHost,
    host.os as HostOS,
    host.container_runtime as Runtime,
    length(path) as EscalationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as FullAttackChain,
    [rel in relationships(path) | type(rel)] as AttackMethods
ORDER BY EscalationSteps
LIMIT 10`,
                description: "This query traces supply chain compromises from malicious packages to host system compromise.",
                expectedResults: "Shows how the compromised 'popular-utility-lib' npm package can lead to container escape and host compromise."
            }
        };

        if (queries[scenarioName]) {
            setTimeout(() => {
                this.runScenarioQuery(queries[scenarioName], scenarioName);
            }, 500); // Small delay to show loading state
        } else {
            resultsDiv.innerHTML = `<div class="error">Scenario '${scenarioName}' not found.</div>`;
        }
    }
    
    updateOverviewPanel(scenarioName) {
        console.log('updateOverviewPanel called with:', scenarioName);
        
        const overviewTitle = document.getElementById('overviewTitle');
        const overviewContent = document.getElementById('overviewContent');
        
        console.log('overviewTitle element:', overviewTitle);
        console.log('overviewContent element:', overviewContent);
        
        const scenarioInfo = {
            'AWS Privilege Escalation': {
                icon: '🔐',
                analysis: 'This query finds privilege escalation paths from developer users to sensitive AWS services, showing both role-based escalation and direct access paths.',
                expectedResults: 'Shows how \'Sarah Chen\' can escalate from developer access to sensitive S3 buckets through role assumption chains and direct access paths.',
                techniques: ['T1078.004 (Valid Accounts: Cloud Accounts)', 'T1548.005 (Abuse Elevation Control Mechanism: Temporary Elevated Cloud Access)', 'T1134.001 (Access Token Manipulation: Token Impersonation/Theft)'],
                riskLevel: 'HIGH',
                steps: ['Developer user assumes IAM role', 'Role escalation through misconfigured trust policies', 'Access to sensitive S3 buckets with PII data']
            },
            'Cross-Cloud Attack Chain': {
                icon: '☁️',
                analysis: 'This query traces cross-cloud attack paths from Azure AD users to AWS services through CI/CD pipelines and direct access.',
                expectedResults: 'Shows how \'Emma Watson\' can access AWS S3 through GitHub Actions CI/CD pipeline and direct cross-cloud access paths.',
                techniques: ['T1078.004 (Valid Accounts: Cloud Accounts)', 'T1195.002 (Supply Chain Compromise: Compromise Software Supply Chain)', 'T1552.004 (Unsecured Credentials: Private Keys)'],
                riskLevel: 'CRITICAL',
                steps: ['Azure AD user accesses CI/CD pipeline', 'Pipeline assumes cross-cloud AWS role via OIDC', 'Deploys to AWS services with elevated permissions']
            },
            'Kubernetes RBAC Escalation': {
                icon: '☸️',
                analysis: 'This query analyzes Kubernetes RBAC configurations and potential privilege escalation paths with risk assessment.',
                expectedResults: 'Shows pod service account bindings, identifies potential escalation to cluster-admin privileges, and highlights high-risk configurations.',
                techniques: ['T1134.001 (Access Token Manipulation: Token Impersonation/Theft)', 'T1548.005 (Abuse Elevation Control Mechanism)', 'T1613 (Container and Resource Discovery)'],
                riskLevel: 'HIGH',
                steps: ['Pod mounts service account token', 'Service account bound to RoleBinding', 'RoleBinding grants escalated cluster permissions']
            },
            'Supply Chain Container Escape': {
                icon: '📦',
                analysis: 'This query traces complete supply chain compromises from malicious packages through container images to host system compromise, including container escape scenarios.',
                expectedResults: 'Shows how the compromised \'popular-utility-lib\' npm package flows through Docker images to pods and can lead to container escape and host compromise.',
                techniques: ['T1195.002 (Supply Chain Compromise)', 'T1610 (Deploy Container)', 'T1611 (Escape to Host)'],
                riskLevel: 'CRITICAL',
                steps: ['Malicious package embedded in container image', 'Image deployed to Kubernetes pod', 'Container escape to compromise host system']
            }
        };
        
        const info = scenarioInfo[scenarioName];
        if (info) {
            overviewTitle.innerHTML = `${info.icon} ${scenarioName}`;
            
            overviewContent.innerHTML = `
                <div style="background: #e8f5e8; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #28a745;">
                    <h4 style="margin: 0 0 10px 0; color: #155724;">📊 Analysis</h4>
                    <p style="margin: 0; color: #155724;">${info.analysis}</p>
                </div>
                
                <div style="background: #e3f2fd; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #2196f3;">
                    <h4 style="margin: 0 0 10px 0; color: #1976d2;">🎯 Expected Results</h4>
                    <p style="margin: 0; color: #1976d2;">${info.expectedResults}</p>
                </div>
                
                <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #ffc107;">
                    <h4 style="margin: 0 0 10px 0; color: #856404;">⚔️ MITRE ATT&CK Techniques</h4>
                    <ul style="margin: 5px 0; padding-left: 20px; color: #856404;">
                        ${info.techniques.map(technique => `<li style="margin: 3px 0;">${technique}</li>`).join('')}
                    </ul>
                </div>
                
                <div style="background: ${info.riskLevel === 'CRITICAL' ? '#f8d7da' : '#fff3cd'}; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid ${info.riskLevel === 'CRITICAL' ? '#dc3545' : '#ffc107'};">
                    <h4 style="margin: 0 0 10px 0; color: ${info.riskLevel === 'CRITICAL' ? '#721c24' : '#856404'};">🚨 Risk Level: ${info.riskLevel}</h4>
                    <p style="margin: 0 0 10px 0; color: ${info.riskLevel === 'CRITICAL' ? '#721c24' : '#856404'};">Attack Steps:</p>
                    <ol style="margin: 0; padding-left: 20px; color: ${info.riskLevel === 'CRITICAL' ? '#721c24' : '#856404'};">
                        ${info.steps.map(step => `<li style="margin: 3px 0;">${step}</li>`).join('')}
                    </ol>
                </div>
                
                <div style="background: #d1ecf1; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #17a2b8;">
                    <h4 style="margin: 0 0 10px 0; color: #0c5460;">💡 Analysis Tips</h4>
                    <ul style="margin: 0; padding-left: 20px; color: #0c5460;">
                        <li>Use the Graph view to visually trace attack paths</li>
                        <li>Click on nodes to see their properties and relationships</li>
                        <li>Look for patterns in MITRE technique mappings</li>
                        <li>Notice how privileges escalate through different cloud services</li>
                    </ul>
                </div>
            `;
        }
    }

    async loadStatistics() {
        try {
            // Since we can't directly connect to Neo4j from the browser due to CORS,
            // we'll show static stats that match our init.cypher data
            const stats = {
                nodes: 35,
                relationships: 25,
                scenarios: 4,
                techniques: 12
            };

            document.getElementById('nodeCount').textContent = stats.nodes;
            document.getElementById('relationshipCount').textContent = stats.relationships;
            document.getElementById('scenarioCount').textContent = stats.scenarios;
            document.getElementById('techniqueCount').textContent = stats.techniques;
        } catch (error) {
            console.error('Error loading statistics:', error);
        }
    }

    async runQuery(query) {
        const resultsDiv = document.getElementById('queryResults');
        resultsDiv.innerHTML = '<div class="loading">Executing query...</div>';

        try {
            // Create URL-encoded query for direct Neo4j browser link
            const encodedQuery = encodeURIComponent(query.trim());
            const neo4jDirectLink = `http://localhost:7474/browser/?cmd=edit&arg=${encodedQuery}`;
            
            resultsDiv.innerHTML = `
                <div class="success">
                    <div class="query-header">
                        <strong>🔍 Analysis Query Ready</strong>
                        <div class="query-actions">
                            <a href="${neo4jDirectLink}" target="_blank" class="neo4j-direct-link">
                                🚀 Run in Neo4j Browser
                            </a>
                            <button onclick="navigator.clipboard.writeText(\`${query.replace(/`/g, '\\`')}\`)" class="copy-btn">
                                📋 Copy Query
                            </button>
                        </div>
                    </div>
                    
                    <div class="query-display">
                        <pre><code>${query}</code></pre>
                    </div>
                    
                    <div class="instructions">
                        <h4>💡 How to Execute:</h4>
                        <ol>
                            <li><strong>Quick way:</strong> Click "🚀 Run in Neo4j Browser" above (opens with query pre-loaded)</li>
                            <li><strong>Manual way:</strong> Open <a href="http://localhost:7474" target="_blank">Neo4j Browser</a>, login (neo4j/cloudsecurity), paste query</li>
                            <li>Click the play button (▶️) to execute and see results</li>
                            <li>Use graph view to visualize attack paths visually</li>
                        </ol>
                    </div>
                </div>
            `;
        } catch (error) {
            resultsDiv.innerHTML = `<div class="error">Error: ${error.message}</div>`;
        }
    }
    
    async runScenarioQuery(scenarioData, scenarioName) {
        const resultsDiv = document.getElementById('queryResults');
        
        try {
            // Create URL-encoded query for direct Neo4j browser link
            const encodedQuery = encodeURIComponent(scenarioData.query.trim());
            const neo4jDirectLink = `http://localhost:7474/browser/?cmd=edit&arg=${encodedQuery}`;
            
            resultsDiv.innerHTML = `
                <div class="query-result-minimal">
                    <div class="query-actions-top">
                        <a href="${neo4jDirectLink}" target="_blank" class="neo4j-direct-link">
                            🚀 Run Analysis
                        </a>
                        <button onclick="navigator.clipboard.writeText(\`${scenarioData.query.replace(/`/g, '\\`')}\`)" class="copy-btn">
                            📋 Copy Query
                        </button>
                    </div>
                    
                    <div class="query-display">
                        <pre><code>${scenarioData.query}</code></pre>
                    </div>
                </div>
            `;
        } catch (error) {
            resultsDiv.innerHTML = `<div class="error">Error loading scenario: ${error.message}</div>`;
        }
    }
}

// Initialize dashboard when page loads
document.addEventListener('DOMContentLoaded', () => {
    window.threatDashboard = new ThreatGraphDashboard();
});