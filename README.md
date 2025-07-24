# 🛡️ Cloud Threat Graph Lab

> **Advanced Security Simulation & Attack Path Analysis**  
> A comprehensive Dockerized lab that simulates realistic cloud attack paths using Neo4j with full MITRE ATT&CK integration.

## 🚀 Quick Start

```bash
# Clone and start the lab
git clone <your-repo-url> cloud-threat-lab
cd cloud-threat-lab
docker-compose up -d

# Wait for services to initialize (about 60 seconds)
# Access the lab:
# - Dashboard: http://localhost:3000
# - Neo4j Browser: http://localhost:7474 (neo4j/cloudsecurity)
```

## 📋 Current Features

### 🎯 8 Attack Scenarios

1. **AWS Privilege Escalation** - Developer user → role assumption → admin access
2. **Cross-Cloud Attack Chain** - Azure AD → CI/CD → AWS role → S3 access  
3. **Kubernetes RBAC Escalation** - Pod → ServiceAccount → ClusterRole escalation
4. **Supply Chain Container Escape** - Compromised package → host compromise
5. **Supply Chain Compromise** - NPM package → CI/CD injection → cloud deployment → secrets access
6. **Secrets Sprawl Attack** - Hardcoded GitHub token → Terraform state → cloud admin credentials
7. **Serverless Attack Chain** - API Gateway → overprivileged Lambda → data exfiltration
8. **Multi-Cloud Identity Federation** - Azure AD guest → OIDC federation → AWS production access

### 🎨 Integrated Dashboard Experience
- **Scenario-Driven Analysis**: Query buttons built directly into each attack scenario panel
- **Auto-Open Neo4j Browser**: Clicking analysis buttons automatically launches Neo4j with pre-loaded queries
- **Inline Query Display**: View and copy queries in bash-style windows within scenario information
- **Dual Analysis Modes**: Choose between table analysis for data overview or graph visualization for attack paths
- **Seamless Workflow**: Attack scenarios directly connected to their analysis without UI confusion

### ⚔️ MITRE ATT&CK Integration
- **25 Techniques** across 11 tactics with comprehensive mappings
- **Detection Guidance** for each technique with specific indicators
- **Mitigation Strategies** with actionable defense recommendations
- **Threat Intelligence** integration for real-world attack context

### 🏗️ Architecture
- **Neo4j Database** (port 7474/7687) - Graph database with attack scenarios
- **Dashboard** (port 3000) - Simple web interface for visualization
- **Data Loader** - Automatically populates the graph with realistic data

## 🔍 Essential Queries

### 1. Overview of All Node Types
```cypher
MATCH (n) 
RETURN labels(n)[0] as NodeType, count(n) as Count 
ORDER BY Count DESC
```

### 2. Find Attack Paths to Sensitive Data
```cypher
MATCH path = (start:User)-[*1..4]->(target:Service)
WHERE start.access_level = 'developer' AND target.contains_pii = true
RETURN 
    start.name as StartUser,
    target.name as TargetService,
    length(path) as PathLength,
    [node in nodes(path) | labels(node)[0]] as NodeTypes
ORDER BY PathLength
LIMIT 5
```

### 3. Privilege Escalation Paths
```cypher
MATCH (user:User)-[:ASSUMES_ROLE|CAN_ESCALATE_TO*1..3]->(role:Role)
WHERE user.access_level = 'developer' 
  AND (role.permissions IS NOT NULL OR role.name CONTAINS 'admin')
RETURN 
    user.name as User,
    user.access_level as StartLevel,
    role.name as TargetRole,
    role.permissions as Permissions
ORDER BY User
```

### 4. Kubernetes RBAC Analysis
```cypher
MATCH (pod:Pod)-[:MOUNTS_SA]->(sa:ServiceAccount)
MATCH (sa)-[:BOUND_TO]->(binding:RoleBinding)-[:GRANTS_ROLE]->(role:Role)
RETURN 
    pod.name as Pod,
    pod.namespace as Namespace,
    sa.name as ServiceAccount,
    role.name as Role,
    role.rules as Permissions
ORDER BY Namespace, Pod
```

### 5. MITRE ATT&CK Technique Mapping
```cypher
MATCH (n)
WHERE n.mitre_techniques IS NOT NULL
UNWIND n.mitre_techniques as technique
RETURN 
    technique as MitreTechnique,
    count(n) as NodesUsingTechnique,
    collect(DISTINCT labels(n)[0]) as NodeTypes
ORDER BY NodesUsingTechnique DESC
```

## 🎓 How to Use the Lab

### 1. Access the Dashboard
- Open http://localhost:3000
- Explore the 4 attack scenarios  
- Click scenario cards to see related queries
- Use the query buttons to analyze attack paths

### 2. Neo4j Browser Deep Dive
- Open http://localhost:7474
- Login: `neo4j` / `cloudsecurity`
- Run the queries above to explore the graph
- Use the graph visualization to see relationships

### 3. Dashboard Workflow

The dashboard provides an integrated analysis experience:

1. **Select Attack Scenarios**: Choose from 8 realistic attack scenarios in the left panel
2. **View Scenario Details**: Each scenario includes:
   - Analysis explanation and risk assessment
   - Expected results and key indicators
   - MITRE ATT&CK techniques and tactics
   - Interpretation tips for findings
3. **Run Analysis**: Click **Table Analysis** or **Graph Visualization**:
   - Neo4j Browser opens automatically with the query pre-loaded
   - Query displays in bash-style window within the scenario panel
   - Copy queries directly for custom analysis
4. **Seamless Experience**: Analysis flows naturally from attack understanding to data exploration

### 4. Explore Attack Scenarios

#### AWS Privilege Escalation
```cypher
MATCH path = (user:AWSUser {access_level: 'developer'})-[*1..3]->(service:AWSService)
WHERE service.contains_pii = true OR service.type = 'S3Bucket'
RETURN 
    user.name as StartUser,
    service.name as TargetService,
    [node in nodes(path) | node.name] as AttackPath,
    [rel in relationships(path) | type(rel)] as Relations
LIMIT 3
```

#### Cross-Cloud Attack Chain  
```cypher
MATCH path = (azure:AzureUser)-[*1..4]->(aws:AWSService)
RETURN 
    azure.name as AzureUser,
    aws.name as AWSTarget,
    [node in nodes(path) | labels(node)[0] + ': ' + node.name] as AttackChain
LIMIT 3
```

## 🔧 Troubleshooting

### ❌ Queries Return No Results

**Most common issue:** Data didn't load properly into Neo4j.

#### Quick Fix:
```bash
# Run the manual data loader
./scripts/quick-fix.sh
```

#### Debug Steps:
1. **Check if ANY data exists:**
   ```cypher
   MATCH (n) RETURN count(n) as TotalNodes
   ```
   If this returns 0, data didn't load.

2. **Manual data loading:**
   ```bash
   docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity -f /var/lib/neo4j/import/init.cypher
   ```

3. **Check data loader logs:**
   ```bash
   docker-compose logs data-loader
   ```

### Services Not Starting
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs neo4j
docker-compose logs dashboard

# Complete restart
docker-compose down && docker-compose up -d
```

### Neo4j Connection Issues
```bash
# Wait for Neo4j to fully initialize (can take 60+ seconds)
docker-compose logs -f neo4j

# Look for: "Remote interface available at http://localhost:7474/"
# Test connection:
docker-compose exec neo4j cypher-shell -u neo4j -p cloudsecurity "RETURN 1;"
```

### Container Issues
```bash
# Clean restart with fresh data
docker-compose down -v
docker-compose up -d
# Wait 2 minutes, then run: ./scripts/load-data.sh
```

## 📊 Lab Statistics

- **Nodes**: 215+ (Users, Roles, Services, Pods, Images, Hosts, MITRE Techniques, etc.)
- **Relationships**: 55+ (Complete attack paths and privilege escalations)
- **MITRE Techniques**: 25 across 11 tactics (T1078, T1548, T1134, T1195, T1190, T1530, etc.)
- **Scenarios**: 8 realistic attack chains with working analysis queries
- **Mock Data**: AWS, Azure, and Kubernetes data ready for Cartography integration
- **Attack Paths**: Verified working user→service relationships for all scenarios

### ✅ **Verified Analysis Coverage:**
- AWS privilege escalation attack paths
- Cross-cloud Azure→AWS compromise chains
- Kubernetes RBAC privilege escalations
- Supply chain container escape scenarios
- CI/CD pipeline compromise attacks
- Secrets sprawl and credential exposure
- Serverless function attack chains
- Multi-cloud identity federation attacks

### 🔍 **Analysis Capabilities:**
- **Dual View Modes**: Table analysis for data overview, graph visualization for attack path tracing
- **Interactive Queries**: Pre-built Cypher queries for each attack scenario
- **Auto-Launch Integration**: Seamless Neo4j Browser integration with one-click analysis
- **Query Customization**: Copy and modify queries for deeper investigation
- **Real Data Results**: All scenarios return actual graph data for meaningful analysis
- **MITRE Context**: Comprehensive ATT&CK technique mapping with defensive guidance

## 📁 **Project Structure**

```
cloud-threat-lab/
├── docker-compose.yml              # Container orchestration
├── README.md                       # This file
├── .gitignore                      # Version control patterns
├── scripts/                        # Utility scripts and data loaders
│   ├── load-data.sh               # Manual data loading
│   ├── load-phase2-data.sh        # Enhanced scenario loader
│   ├── quick-fix.sh               # Fix missing relationships
│   └── reload-fresh-data.sh       # Complete data reload
├── docs/                          # Comprehensive documentation
│   ├── attack-scenarios-enhanced.md # Detailed scenario documentation
│   ├── mitre-integration-guide.md   # MITRE ATT&CK integration guide
│   ├── WORKING_QUERIES.md          # Verified query examples
│   └── DEBUG_QUERIES.md            # Troubleshooting guide
├── cartography/                   # Mock cloud data for future integration
│   ├── mock-aws-data.json         # Realistic AWS infrastructure data
│   ├── mock-azure-data.json       # Azure resource inventory
│   └── mock-k8s-data.json         # Kubernetes cluster configuration
├── neo4j/                         # Graph database configuration and data
│   ├── init-complete.cypher       # Core attack scenario data
│   ├── phase2-scenarios.cypher    # Advanced attack scenarios
│   └── mitre-integration.cypher   # MITRE ATT&CK technique mappings
└── dashboard/                     # Interactive web interface
    ├── index.html                 # Main dashboard with 8 scenarios
    ├── app.js                     # Interactive analysis functionality
    ├── style.css                  # Dashboard styling and UX
    └── Dockerfile
```

## 🔮 Upcoming Features

### 📊 Dynamic Asset Discovery
- Cartography integration for live cloud asset mapping
- Mock cloud API responses simulating real environments
- Asset discovery workflow with realistic data ingestion
- Real-time graph updates as "assets are discovered"
- Multi-cloud inventory simulation (AWS, Azure, GCP)

### 🎨 Advanced Visualization
- Modern React/Vue dashboard with enhanced UX
- Interactive graph visualization with D3.js or vis.js
- Jupyter notebooks for threat research and analysis
- Query builder interface for non-technical users
- Attack simulation engine with automated progression

### 🔧 Enterprise Integration
- Export capabilities (JSON, CSV, GraphML, MITRE Navigator)
- SIEM/SOAR integration for real-world threat hunting
- Metrics collection and analytics dashboard
- API endpoints for custom integrations
- Automated red team scenario generation

### 🌐 Community Features
- Scenario marketplace for sharing custom attack paths
- Community-contributed MITRE technique mappings
- Collaborative threat research workspace
- Import/export functionality for threat intelligence sharing

## 🛡️ Security Notes

- **No real cloud credentials required** - This is a simulation using fake data
- **Defensive focus** - Designed for security analysis and education
- **Local environment** - All data stays on your machine
- **Educational purpose** - For learning cloud security concepts

## 🤝 Contributing

Contributions welcome for:
- Additional realistic attack scenarios
- Enhanced MITRE ATT&CK technique mappings
- New visualization and analysis features
- Documentation and educational content improvements
- Integration with security tools and frameworks

## 📄 License

MIT License - See LICENSE file for details.

---

## 📊 Evolution & Impact

### 🎯 Current Capabilities
- **8 Realistic Attack Scenarios** covering major cloud security threats
- **215+ Graph Nodes** representing comprehensive cloud infrastructure
- **25 MITRE ATT&CK Techniques** with detection and mitigation guidance
- **Integrated Analysis Workflow** connecting attack understanding to data exploration
- **Dual Visualization Modes** for both tabular analysis and graph path tracing
- **Mock Cloud Data** foundation ready for dynamic asset discovery integration
- **100% Working Queries** - all scenarios return meaningful analysis results

### 🔍 Value for Security Teams
- **Threat Modeling**: Visualize realistic attack paths in cloud environments
- **Red Team Planning**: Understand multi-stage attack progressions
- **Blue Team Training**: Practice threat hunting with realistic data
- **Risk Assessment**: Identify critical privilege escalation paths
- **MITRE Mapping**: Connect attack techniques to defensive strategies
- **Educational Tool**: Learn cloud security concepts through hands-on analysis