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
        // No standalone query buttons - all queries are now integrated into scenarios
    }

    displayScenarios() {
        const scenarios = [
            {
                name: "AWS Privilege Escalation",
                description: "Developer user escalates to admin via role assumption",
                severity: "HIGH",
                techniques: ["T1078.004", "T1548.005", "T1134.001"],
            },
            {
                name: "Cross-Cloud Attack Chain", 
                description: "Azure AD user compromises AWS resources via CI/CD",
                severity: "CRITICAL",
                techniques: ["T1078.004", "T1195.002", "T1552.004"],
            },
            {
                name: "Kubernetes RBAC Escalation",
                description: "Pod service account escalates to cluster admin", 
                severity: "HIGH",
                techniques: ["T1134.001", "T1548.005", "T1613"],
            },
            {
                name: "Supply Chain Container Escape",
                description: "Compromised package leads to host compromise",
                severity: "CRITICAL", 
                techniques: ["T1195.002", "T1610", "T1611"],
            },
            {
                name: "Supply Chain Compromise",
                description: "Compromised npm package → CI/CD injection → cloud deployment",
                severity: "CRITICAL",
                techniques: ["T1195.002", "T1609", "T1552.007"],
            },
            {
                name: "Secrets Sprawl Attack",
                description: "Hardcoded GitHub token → Terraform state → cloud admin credentials",
                severity: "HIGH",
                techniques: ["T1552.001", "T1552.004", "T1078.004"],
            },
            {
                name: "Serverless Attack Chain",
                description: "API Gateway → overprivileged Lambda → service chains → data exfiltration",
                severity: "HIGH",
                techniques: ["T1190", "T1098.001", "T1530"],
            },
            {
                name: "Multi-Cloud Identity Federation Attack",
                description: "Azure AD federated with AWS → cross-cloud escalation → federated identity abuse",
                severity: "CRITICAL",
                techniques: ["T1078.004", "T1550.001", "T1098.001"],
            }
        ];

        const scenarioList = document.getElementById('scenarioList');
        scenarioList.innerHTML = scenarios.map(scenario => `
            <li class="scenario-item" onclick="window.threatDashboard.exploreScenario('${scenario.name}')">
                <div class="scenario-header">
                    <div class="scenario-name">${scenario.name}</div>
                </div>
                <div class="scenario-description">${scenario.description}</div>
                <div class="scenario-footer">
                    <div class="severity ${scenario.severity}">${scenario.severity}</div>
                    <div style="font-size: 0.8em; color: #6c757d;">
                        MITRE: ${scenario.techniques.join(', ')}
                    </div>
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
            },
            'Supply Chain Compromise': {
                query: `// Trace complete supply chain attack from npm package to cloud deployment
MATCH path = (pkg:NPMPackage)-[*1..5]->(secret:SecretsManager)
WHERE pkg.compromised = true
RETURN 
    pkg.name as CompromisedPackage,
    pkg.version as Version,
    pkg.injection_method as InjectionMethod,
    secret.name as TargetSecrets,
    secret.contains_pii as ContainsPII,
    length(path) as AttackSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as SupplyChainPath,
    [rel in relationships(path) | type(rel)] as AttackMethods
ORDER BY AttackSteps
LIMIT 10`,
                description: "This query traces npm package compromise through CI/CD to cloud deployment and secrets access.",
                expectedResults: "Shows how 'popular-utility-lib' compromise flows through build pipeline to ECS task accessing production secrets."
            },
            'Secrets Sprawl Attack': {
                query: `// Follow hardcoded secrets from public repos to cloud admin access
MATCH path = (token:HardcodedToken)-[*1..5]->(bucket:S3AdminBucket)
WHERE token.still_valid = true
RETURN 
    token.name as ExposedToken,
    token.location as TokenLocation,
    token.scope as TokenScope,
    bucket.name as AdminBucket,
    bucket.contains_pii as ContainsPII,
    length(path) as EscalationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as SecretsPath,
    [rel in relationships(path) | type(rel)] as EscalationMethods
ORDER BY EscalationSteps
LIMIT 10`,
                description: "This query follows hardcoded GitHub tokens through Terraform state to cloud admin credentials.",
                expectedResults: "Shows how exposed GitHub token leads to private repo access, Terraform state exposure, and AWS admin bucket access."
            },
            'Serverless Attack Chain': {
                query: `// Map serverless attack paths from API Gateway to data exfiltration
MATCH path = (api:APIGateway)-[*1..4]->(data:S3DataLake)
WHERE api.authentication = 'none'
RETURN 
    api.name as APIGateway,
    api.stage as Stage,
    api.authentication as Authentication,
    data.name as DataLake,
    data.contains_pii as ContainsPII,
    data.public_access_blocked as PublicBlocked,
    length(path) as AttackSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as ServerlessChain,
    [rel in relationships(path) | type(rel)] as AttackMethods
ORDER BY AttackSteps
LIMIT 10`,
                description: "This query maps serverless attack chains from unauthenticated API Gateway to data exfiltration.",
                expectedResults: "Shows how unauthenticated API Gateway leads through overprivileged Lambda to customer data lake access."
            },
            'Multi-Cloud Identity Federation Attack': {
                query: `// Trace multi-cloud federation attacks from Azure AD to AWS production
MATCH path = (azure:AzureADUser)-[*1..5]->(prod:ProductionAccount)
WHERE azure.user_type = 'Guest' AND azure.mfa_enabled = false
RETURN 
    azure.name as AzureUser,
    azure.user_type as UserType,
    azure.mfa_enabled as MFAEnabled,
    prod.name as ProductionAccount,
    prod.contains_sensitive_data as ContainsSensitiveData,
    length(path) as FederationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as FederationChain,
    [rel in relationships(path) | type(rel)] as FederationMethods
ORDER BY FederationSteps
LIMIT 10`,
                description: "This query traces multi-cloud identity federation attacks from Azure AD guest users to AWS production accounts.",
                expectedResults: "Shows how external Azure AD contractor escalates through OIDC federation to AWS production account access."
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
            },
            'Supply Chain Compromise': {
                icon: '🏭',
                analysis: 'This query traces complete supply chain attacks from compromised npm packages through CI/CD pipelines to cloud deployment and secrets access.',
                expectedResults: 'Shows how \'popular-utility-lib\' npm package compromise flows through GitHub Actions build pipeline to ECS task with access to production secrets.',
                techniques: ['T1195.002 (Supply Chain Compromise: Compromise Software Supply Chain)', 'T1609 (Container Administration Command)', 'T1552.007 (Unsecured Credentials: Container API)'],
                riskLevel: 'CRITICAL',
                steps: ['Malicious npm package injected via typosquatting', 'CI/CD pipeline builds and deploys compromised container', 'ECS task accesses AWS Secrets Manager with elevated permissions']
            },
            'Secrets Sprawl Attack': {
                icon: '🔑',
                analysis: 'This query follows hardcoded secrets exposure from public repositories through Terraform state files to cloud admin credentials compromise.',
                expectedResults: 'Shows how hardcoded GitHub token in public repo leads to private infrastructure repo access, Terraform state exposure, and AWS admin bucket compromise.',
                techniques: ['T1552.001 (Unsecured Credentials: Credentials In Files)', 'T1552.004 (Unsecured Credentials: Private Keys)', 'T1078.004 (Valid Accounts: Cloud Accounts)'],
                riskLevel: 'HIGH',
                steps: ['GitHub PAT token hardcoded in public repository', 'Token grants access to private infrastructure repository', 'Terraform state file reveals AWS admin credentials for S3 access']
            },
            'Serverless Attack Chain': {
                icon: '⚡',
                analysis: 'This query maps serverless attack chains from unauthenticated API Gateway endpoints through overprivileged Lambda functions to data exfiltration.',
                expectedResults: 'Shows how unauthenticated API Gateway leads through overprivileged Lambda execution role to customer data lake with PII access.',
                techniques: ['T1190 (Exploit Public-Facing Application)', 'T1098.001 (Account Manipulation: Additional Cloud Credentials)', 'T1530 (Data from Cloud Storage Object)'],
                riskLevel: 'HIGH',
                steps: ['Unauthenticated API Gateway endpoint exploitation', 'Lambda function executes with overprivileged IAM role', 'Role grants access to DynamoDB tables and S3 data lake with PII']
            },
            'Multi-Cloud Identity Federation Attack': {
                icon: '🌐',
                analysis: 'This query traces multi-cloud identity federation attacks from Azure AD guest users through OIDC providers to AWS production account access.',
                expectedResults: 'Shows how external Azure AD contractor with disabled MFA escalates through OIDC federation to AWS production account with sensitive data access.',
                techniques: ['T1078.004 (Valid Accounts: Cloud Accounts)', 'T1550.001 (Use Alternate Authentication Material: Application Access Token)', 'T1098.001 (Account Manipulation: Additional Cloud Credentials)'],
                riskLevel: 'CRITICAL',
                steps: ['External Azure AD guest user without MFA accesses OIDC provider', 'OIDC provider trusts Azure AD and issues AWS federated role tokens', 'Cross-account trust grants access to AWS production account with sensitive data']
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
                
                <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 15px 0; border: 2px solid #dee2e6;">
                    <h4 style="margin: 0 0 15px 0; color: #2c3e50;">🔍 Attack Analysis</h4>
                    <p style="margin: 0 0 15px 0; color: #6c757d; font-size: 0.9em;">
                        Choose your analysis method to explore this attack scenario:
                    </p>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button class="scenario-analysis-btn" onclick="window.threatDashboard.runScenarioTableQuery('${scenarioName}')" 
                                style="background: #17a2b8; color: white; border: none; padding: 10px 16px; border-radius: 6px; cursor: pointer; font-size: 0.9em;">
                            📊 Table Analysis
                        </button>
                        <button class="scenario-analysis-btn" onclick="window.threatDashboard.runScenarioGraphQuery('${scenarioName}')" 
                                style="background: #28a745; color: white; border: none; padding: 10px 16px; border-radius: 6px; cursor: pointer; font-size: 0.9em;">
                            🌐 Graph Visualization
                        </button>
                    </div>
                    <div style="margin-top: 12px; padding: 10px; background: #e8f5e8; border-radius: 4px; border-left: 3px solid #28a745;">
                        <small style="color: #155724;">
                            <strong>📊 Table Analysis:</strong> Shows detailed data in rows and columns<br>
                            <strong>🌐 Graph Visualization:</strong> Shows visual attack paths with nodes and relationships (use Graph tab in Neo4j Browser)
                        </small>
                    </div>
                </div>
            `;
        }
    }

    async loadStatistics() {
        try {
            // Statistics reflecting enhanced data and MITRE integration
            const stats = {
                nodes: 221,
                relationships: 97,
                scenarios: 8,
                techniques: 22
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
                        <h4>💡 How to Execute & See Graph Visualization:</h4>
                        <ol>
                            <li><strong>Quick way:</strong> Click "🚀 Run in Neo4j Browser" above (opens with query pre-loaded)</li>
                            <li><strong>Manual way:</strong> Open <a href="http://localhost:7474" target="_blank">Neo4j Browser</a>, login (neo4j/cloudsecurity), paste query</li>
                            <li>Click the play button (▶️) to execute the query</li>
                            <li><strong>📊 For Graph View:</strong> After results appear, click the <strong>"Graph"</strong> tab (next to Table/Text tabs)</li>
                            <li><strong>🎯 Visual Attack Paths:</strong> You'll see nodes as circles, relationships as arrows - drag nodes to explore!</li>
                        </ol>
                        <div class="graph-tip">
                            <strong>💡 Pro Tip:</strong> The Graph tab only appears when queries return paths or relationships. All attack path queries above return visual graphs!
                        </div>
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

    // New function to run table analysis queries
    runScenarioTableQuery(scenarioName) {
        console.log('Running table query for:', scenarioName);
        
        // Get the tabular query for this scenario
        const queries = {
            'AWS Privilege Escalation': {
                query: `MATCH path = (user:User)-[*1..3]->(service:Service)
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
LIMIT 10`
            },
            'Cross-Cloud Attack Chain': {
                query: `MATCH path = (azure:User)-[*1..4]->(aws:Service)
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
LIMIT 10`
            },
            'Supply Chain Compromise': {
                query: `MATCH path = (pkg:NPMPackage)-[*1..5]->(secret:SecretsManager)
WHERE pkg.compromised = true
RETURN 
    pkg.name as CompromisedPackage,
    pkg.version as Version,
    pkg.injection_method as InjectionMethod,
    secret.name as TargetSecrets,
    secret.contains_pii as ContainsPII,
    length(path) as AttackSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as SupplyChainPath,
    [rel in relationships(path) | type(rel)] as AttackMethods
ORDER BY AttackSteps
LIMIT 10`
            },
            'Secrets Sprawl Attack': {
                query: `MATCH path = (token:HardcodedToken)-[*1..5]->(bucket:S3AdminBucket)
WHERE token.still_valid = true
RETURN 
    token.name as ExposedToken,
    token.location as TokenLocation,
    token.scope as TokenScope,
    bucket.name as AdminBucket,
    bucket.contains_pii as ContainsPII,
    length(path) as EscalationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as SecretsPath,
    [rel in relationships(path) | type(rel)] as EscalationMethods
ORDER BY EscalationSteps
LIMIT 10`
            },
            'Serverless Attack Chain': {
                query: `MATCH path = (api:APIGateway)-[*1..4]->(data:S3DataLake)
WHERE api.authentication = 'none'
RETURN 
    api.name as APIGateway,
    api.stage as Stage,
    api.authentication as Authentication,
    data.name as DataLake,
    data.contains_pii as ContainsPII,
    length(path) as AttackSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as ServerlessChain,
    [rel in relationships(path) | type(rel)] as AttackMethods
ORDER BY AttackSteps
LIMIT 10`
            },
            'Multi-Cloud Identity Federation Attack': {
                query: `MATCH path = (azure:AzureADUser)-[*1..4]->(prod:ProductionAccount)
WHERE azure.user_type = 'Guest' AND azure.mfa_enabled = false
RETURN 
    azure.name as AzureUser,
    azure.user_type as UserType,
    azure.mfa_enabled as MFAEnabled,
    prod.name as ProductionAccount,
    prod.contains_sensitive_data as ContainsSensitiveData,
    length(path) as FederationSteps,
    [node in nodes(path) | labels(node)[0] + ': ' + coalesce(node.name, node.id)] as FederationPath,
    [rel in relationships(path) | type(rel)] as FederationMethods
ORDER BY FederationSteps
LIMIT 10`
            }
        };

        const queryData = queries[scenarioName];
        if (queryData) {
            this.showQueryInScenario(scenarioName, queryData.query, 'Table Analysis', '📊');
            this.openInNeo4j(queryData.query);
        }
    }

    // New function to run graph visualization queries
    runScenarioGraphQuery(scenarioName) {
        console.log('Running graph query for:', scenarioName);
        
        // Map scenarios to their path-returning queries
        const graphQueries = {
            'AWS Privilege Escalation': `MATCH path = (start:User)-[*1..4]->(target:Service)
WHERE start.access_level = 'developer' AND target.contains_pii = true
RETURN path
ORDER BY length(path)
LIMIT 5`,
            
            'Cross-Cloud Attack Chain': `MATCH path = (azure:User)-[*1..4]->(aws:Service)
WHERE azure.tenant_id IS NOT NULL AND (aws.type = 'S3Bucket' OR labels(aws) CONTAINS 'AWSService') 
RETURN path
ORDER BY length(path)
LIMIT 5`,
            
            'Supply Chain Compromise': `MATCH path = (pkg:NPMPackage)-[*1..5]->(secret:SecretsManager)
WHERE pkg.compromised = true
RETURN path
ORDER BY length(path)
LIMIT 5`,
            
            'Secrets Sprawl Attack': `MATCH path = (token:HardcodedToken)-[*1..5]->(bucket:S3AdminBucket)
WHERE token.still_valid = true
RETURN path
ORDER BY length(path)
LIMIT 5`,
            
            'Serverless Attack Chain': `MATCH path = (api:APIGateway)-[*1..4]->(data:S3DataLake)
WHERE api.authentication = 'none'
RETURN path
ORDER BY length(path)
LIMIT 5`,
            
            'Multi-Cloud Identity Federation Attack': `MATCH path = (azure:AzureADUser)-[*1..4]->(prod:ProductionAccount)
WHERE azure.user_type = 'Guest' AND azure.mfa_enabled = false
RETURN path
ORDER BY length(path)
LIMIT 5`,
            
            'Kubernetes RBAC Escalation': `MATCH path = (pod:K8sResource)-[*1..3]->(role:Role)
WHERE pod.type = 'Pod' AND role.name CONTAINS 'admin'
RETURN path
ORDER BY length(path)
LIMIT 5`,
            
            'Supply Chain Container Escape': `MATCH path = (pkg:Package)-[*1..5]->(host:Host)
WHERE pkg.compromised = true
RETURN path
ORDER BY length(path)
LIMIT 5`
        };

        const query = graphQueries[scenarioName];
        if (query) {
            this.showQueryInScenario(scenarioName, query, 'Graph Visualization', '🌐');
            this.openInNeo4j(query);
        }
    }

    // New function to show query in scenario panel
    showQueryInScenario(scenarioName, query, analysisType, icon) {
        // Update the scenario information to show the query
        const overviewContent = document.getElementById('overviewContent');
        const overviewTitle = document.getElementById('overviewTitle');
        
        const scenarioInfo = {
            'AWS Privilege Escalation': {
                icon: '🎯',
                analysis: 'This query finds attack paths from developer users to sensitive AWS services containing PII data.',
                expectedResults: 'Shows how \'Sarah Chen\' can access sensitive S3 buckets through various paths including direct access and role assumptions.',
                techniques: ['T1078.004 (Valid Accounts: Cloud Accounts)', 'T1548.005 (Abuse Elevation Control Mechanism: Temporary Elevated Cloud Access)', 'T1134.001 (Access Token Manipulation: Token Impersonation/Theft)'],
                riskLevel: 'HIGH',
                steps: ['Developer user accesses AWS console with limited permissions', 'User discovers and assumes higher-privileged IAM role', 'Escalated role grants access to sensitive S3 buckets containing PII']
            },
            'Cross-Cloud Attack Chain': {
                icon: '🔗',
                analysis: 'This query traces cross-cloud attack paths from Azure AD users to AWS services through CI/CD pipelines.',
                expectedResults: 'Shows how \'Emma Watson\' can access AWS S3 through GitHub Actions CI/CD pipeline federation paths.',
                techniques: ['T1078.004 (Valid Accounts: Cloud Accounts)', 'T1195.002 (Supply Chain Compromise: Compromise Software Supply Chain)', 'T1552.004 (Unsecured Credentials: Private Keys)'],
                riskLevel: 'CRITICAL',
                steps: ['Azure AD user accesses GitHub Actions with elevated permissions', 'CI/CD pipeline uses federated OIDC to assume AWS IAM role', 'Cross-account trust grants access to production AWS S3 buckets']
            },
            'Supply Chain Compromise': {
                icon: '📦',
                analysis: 'This query traces complete supply chain attacks from compromised npm packages through CI/CD to cloud deployment and secrets access.',
                expectedResults: 'Shows how compromised \'popular-utility-lib\' npm package leads through CI/CD pipeline to AWS Secrets Manager access.',
                techniques: ['T1195.002 (Supply Chain Compromise: Compromise Software Supply Chain)', 'T1609 (Container Administration Command)', 'T1552.007 (Unsecured Credentials: Container API)'],
                riskLevel: 'CRITICAL',
                steps: ['Malicious npm package injected via typosquatting', 'CI/CD pipeline builds and deploys compromised container', 'ECS task accesses AWS Secrets Manager with elevated permissions']
            },
            'Secrets Sprawl Attack': {
                icon: '🔑',
                analysis: 'This query follows hardcoded secrets exposure from public repositories through Terraform state files to cloud admin credentials compromise.',
                expectedResults: 'Shows how hardcoded GitHub token in public repo leads to private infrastructure repo access, Terraform state exposure, and AWS admin bucket compromise.',
                techniques: ['T1552.001 (Unsecured Credentials: Credentials In Files)', 'T1552.004 (Unsecured Credentials: Private Keys)', 'T1078.004 (Valid Accounts: Cloud Accounts)'],
                riskLevel: 'HIGH',
                steps: ['GitHub PAT token hardcoded in public repository', 'Token grants access to private infrastructure repository', 'Terraform state file reveals AWS admin credentials for S3 access']
            },
            'Serverless Attack Chain': {
                icon: '⚡',
                analysis: 'This query maps serverless attack chains from unauthenticated API Gateway endpoints through overprivileged Lambda functions to data exfiltration.',
                expectedResults: 'Shows how unauthenticated API Gateway leads through overprivileged Lambda execution role to customer data lake with PII access.',
                techniques: ['T1190 (Exploit Public-Facing Application)', 'T1098.001 (Account Manipulation: Additional Cloud Credentials)', 'T1530 (Data from Cloud Storage Object)'],
                riskLevel: 'HIGH',
                steps: ['Unauthenticated API Gateway endpoint exploitation', 'Lambda function executes with overprivileged IAM role', 'Role grants access to DynamoDB tables and S3 data lake with PII']
            },
            'Multi-Cloud Identity Federation Attack': {
                icon: '🌐',
                analysis: 'This query traces multi-cloud identity federation attacks from Azure AD guest users through OIDC providers to AWS production account access.',
                expectedResults: 'Shows how external Azure AD contractor with disabled MFA escalates through OIDC federation to AWS production account with sensitive data access.',
                techniques: ['T1078.004 (Valid Accounts: Cloud Accounts)', 'T1550.001 (Use Alternate Authentication Material: Application Access Token)', 'T1098.001 (Account Manipulation: Additional Cloud Credentials)'],
                riskLevel: 'CRITICAL',
                steps: ['External Azure AD guest user without MFA accesses OIDC provider', 'OIDC provider trusts Azure AD and issues AWS federated role tokens', 'Cross-account trust grants access to AWS production account with sensitive data']
            },
            'Kubernetes RBAC Escalation': {
                icon: '☸️',
                analysis: 'This query analyzes Kubernetes RBAC configurations and potential privilege escalation paths from pods to cluster admin roles.',
                expectedResults: 'Shows pod service account bindings and identifies potential escalation to cluster-admin privileges.',
                techniques: ['T1134.001 (Access Token Manipulation: Token Impersonation/Theft)', 'T1548.005 (Abuse Elevation Control Mechanism: Temporary Elevated Cloud Access)', 'T1613 (Container and Resource Discovery)'],
                riskLevel: 'HIGH',
                steps: ['Pod service account escalates to cluster admin', 'Service account escalates to cluster admin', 'Admin access grants full cluster control']
            },
            'Supply Chain Container Escape': {
                icon: '🏭',
                analysis: 'This query traces supply chain compromises from malicious packages to host system compromise through container escape techniques.',
                expectedResults: 'Shows how the compromised \'popular-utility-lib\' npm package can lead to container escape and host compromise.',
                techniques: ['T1195.002 (Supply Chain Compromise: Compromise Software Supply Chain)', 'T1610 (Deploy Container)', 'T1611 (Escape to Host)'],
                riskLevel: 'CRITICAL',
                steps: ['Compromised package deployed in container environment', 'Container escape leads to host compromise', 'Host compromise leads to full infrastructure control']
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
                
                <div style="background: #2d3748; border-radius: 8px; margin: 15px 0; overflow: hidden;">
                    <div style="background: #4a5568; color: white; padding: 12px 16px; font-size: 0.9em; display: flex; justify-content: space-between; align-items: center;">
                        <span>${icon} ${analysisType} Query</span>
                        <button onclick="navigator.clipboard.writeText(\`${query.replace(/`/g, '\\`')}\`)" 
                                style="background: #28a745; color: white; border: none; padding: 4px 8px; border-radius: 4px; cursor: pointer; font-size: 0.8em;">
                            📋 Copy
                        </button>
                    </div>
                    <pre style="margin: 0; padding: 20px; overflow-x: auto; background: #2d3748; color: #e2e8f0; font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace; font-size: 0.9em; line-height: 1.5;">${query}</pre>
                </div>
                
                <div style="background: #d4edda; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #28a745;">
                    <h4 style="margin: 0 0 10px 0; color: #155724;">🚀 Query Execution</h4>
                    <p style="margin: 0; color: #155724; font-size: 0.9em;">
                        <strong>Neo4j Browser should have opened automatically!</strong> If not, go to 
                        <a href="http://localhost:7474" target="_blank" style="color: #155724; text-decoration: underline;">http://localhost:7474</a>
                        and paste the query above.
                    </p>
                    <p style="margin: 8px 0 0 0; color: #155724; font-size: 0.9em;">
                        Login: <code>neo4j</code> / <code>cloudsecurity</code> → 
                        ${analysisType === 'Graph Visualization' ? '<strong>Click "Graph" tab after running</strong>' : 'View results in Table tab'}
                    </p>
                </div>
            `;
        }
    }

    // New function to auto-open Neo4j Browser
    openInNeo4j(query) {
        const encodedQuery = encodeURIComponent(query.trim());
        const neo4jDirectLink = `http://localhost:7474/browser/?cmd=edit&arg=${encodedQuery}`;
        window.open(neo4jDirectLink, '_blank');
    }
    
    showHelp() {
        const modal = document.getElementById('helpModal');
        const helpContent = document.getElementById('helpContent');
        
        modal.style.display = 'block';
        
        // Load comprehensive help content
        helpContent.innerHTML = `
            <div class="help-section">
                <h3>🚀 Quick Start</h3>
                <p><strong>1. Select a scenario</strong> from the left panel to see detailed analysis information.</p>
                <p><strong>2. Click "🚀 Run Analysis"</strong> to open Neo4j Browser with the query pre-loaded.</p>
                <p><strong>3. Login to Neo4j</strong> with username: <code>neo4j</code> and password: <code>cloudsecurity</code></p>
                <p><strong>4. Hit the play button (▶️)</strong> to execute the query and see results.</p>
            </div>

            <div class="help-section">
                <h3>🎯 Attack Scenarios</h3>
                <ul>
                    <li><strong>AWS Privilege Escalation:</strong> Developer user escalates to admin via role assumption</li>
                    <li><strong>Cross-Cloud Attack Chain:</strong> Azure AD user compromises AWS resources via CI/CD</li>
                    <li><strong>Kubernetes RBAC Escalation:</strong> Pod service account escalates to cluster admin</li>
                    <li><strong>Supply Chain Container Escape:</strong> Compromised package leads to host compromise</li>
                </ul>
            </div>

            <div class="help-section">
                <h3>🔍 Essential Queries</h3>
                
                <h4>Basic Node Overview</h4>
                <pre><code>MATCH (n) RETURN labels(n)[0] as NodeType, count(n) as Count ORDER BY Count DESC</code></pre>
                
                <h4>User-Service Access Paths</h4>
                <pre><code>MATCH (u:User)-[r:CAN_ACCESS]->(s:Service)
RETURN u.name as User, s.name as Service, r.method as AccessMethod
ORDER BY User</code></pre>

                <h4>Attack Path Analysis</h4>
                <pre><code>MATCH path = (u:User)-[*1..3]->(s:Service)
WHERE u.access_level = 'developer' AND s.contains_pii = true
RETURN u.name, s.name, length(path) as steps
ORDER BY steps</code></pre>
            </div>

            <div class="help-section">
                <h3>🛠️ Troubleshooting</h3>
                
                <h4>If queries return no results:</h4>
                <ol>
                    <li>Check if any data exists: <code>MATCH (n) RETURN count(n) as TotalNodes</code></li>
                    <li>Check relationships: <code>MATCH ()-[r]->() RETURN type(r), count(r) ORDER BY count(r) DESC</code></li>
                    <li>Run manual data fix: <code>./scripts/quick-fix.sh</code></li>
                </ol>

                <h4>If services aren't starting:</h4>
                <pre><code># Check container status
docker-compose ps

# Restart services
docker-compose down && docker-compose up -d

# Check logs
docker-compose logs neo4j</code></pre>
            </div>

            <div class="help-section">
                <h3>📊 Lab Statistics</h3>
                <ul>
                    <li><strong>Nodes:</strong> 68 (Users, Roles, Services, Pods, Images, Hosts)</li>
                    <li><strong>Relationships:</strong> 30+ (Complete attack paths and privilege escalations)</li>
                    <li><strong>MITRE Techniques:</strong> 12 (T1078, T1548, T1134, T1195, etc.)</li>
                    <li><strong>Scenarios:</strong> 4 realistic attack chains with full connectivity</li>
                </ul>
            </div>

            <div class="help-section">
                <h3>📁 Project Structure</h3>
                <ul>
                    <li><code>scripts/</code> - All shell scripts and cypher files for data management</li>
                    <li><code>docs/</code> - Additional documentation and query references</li>
                    <li><code>neo4j/</code> - Neo4j data and configuration files</li>
                    <li><code>dashboard/</code> - Web dashboard source code</li>
                </ul>
            </div>

            <div class="help-section">
                <h3>⚔️ MITRE ATT&CK Integration</h3>
                <p>Each scenario is mapped to specific MITRE ATT&CK techniques:</p>
                <ul>
                    <li><strong>T1078.004:</strong> Valid Accounts - Cloud Accounts</li>
                    <li><strong>T1548.005:</strong> Abuse Elevation Control Mechanism</li>
                    <li><strong>T1134.001:</strong> Access Token Manipulation</li>
                    <li><strong>T1195.002:</strong> Supply Chain Compromise</li>
                    <li><strong>T1552.004:</strong> Unsecured Credentials - Private Keys</li>
                    <li><strong>T1610:</strong> Deploy Container</li>
                    <li><strong>T1611:</strong> Escape to Host</li>
                    <li><strong>T1613:</strong> Container and Resource Discovery</li>
                </ul>
            </div>

            <div class="help-section">
                <h3>🔮 Future Phases</h3>
                <p><strong>Enhanced Features:</strong> Comprehensive MITRE mapping, mock Cartography data</p>
                <p><strong>Phase 3:</strong> Cartography integration with asset discovery simulation</p>
                <p><strong>Phase 4:</strong> Interactive React dashboard, Jupyter notebooks</p>
                <p><strong>Phase 5:</strong> Advanced analytics, metrics collection, export capabilities</p>
            </div>
        `;
    }
    
    closeHelp() {
        const modal = document.getElementById('helpModal');
        modal.style.display = 'none';
    }
}

// Initialize dashboard when page loads
document.addEventListener('DOMContentLoaded', () => {
    window.threatDashboard = new ThreatGraphDashboard();
    
    // Close modal when clicking outside of it
    window.onclick = function(event) {
        const modal = document.getElementById('helpModal');
        if (event.target === modal) {
            window.threatDashboard.closeHelp();
        }
    }
});