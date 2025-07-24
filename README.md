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

- **Nodes**: 300+ (Users, Roles, Services, Pods, Images, Hosts, MITRE Techniques, Discovered Assets, etc.)
- **Relationships**: 80+ (Complete attack paths, privilege escalations, and discovered connections)
- **MITRE Techniques**: 31 across 13 tactics (T1078, T1548, T1134, T1195, T1190, T1530, T1526, T1087, etc.)
- **Scenarios**: 10 realistic attack chains including 2 new discovery-based scenarios
- **Mock Data**: Comprehensive AWS, Azure, and Kubernetes datasets with realistic configurations
- **Asset Discovery**: 7-phase progressive discovery simulation with 50+ mock cloud resources
- **Attack Paths**: Verified working relationships including discovery-revealed hidden paths

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
├── docker-compose.yml              # Container orchestration with Cartography + LocalStack
├── README.md                       # This file with Phase 3 documentation
├── .gitignore                      # Version control patterns
├── scripts/                        # Utility scripts and discovery management
│   ├── load-data.sh               # Manual data loading
│   ├── load-phase2-data.sh        # Enhanced scenario loader
│   ├── start-discovery-simulation.sh # Asset discovery trigger (NEW)
│   ├── reset-environment.sh       # Environment reset to baseline (NEW)
│   ├── quick-fix.sh               # Fix missing relationships
│   └── reload-fresh-data.sh       # Complete data reload
├── docs/                          # Comprehensive documentation
│   ├── attack-scenarios-enhanced.md # Detailed scenario documentation
│   ├── mitre-integration-guide.md   # MITRE ATT&CK integration guide
│   ├── WORKING_QUERIES.md          # Verified query examples
│   └── DEBUG_QUERIES.md            # Troubleshooting guide
├── cartography/                   # Cartography integration & mock data (ENHANCED)
│   ├── Dockerfile                 # Cartography container configuration
│   ├── run-discovery.sh           # Discovery simulation script
│   ├── simulate-discovery.py      # Python discovery simulator
│   ├── config/
│   │   └── config.yaml           # Cartography configuration
│   └── mock-data/                # Realistic cloud infrastructure datasets
│       ├── aws-resources.json    # Comprehensive AWS infrastructure
│       ├── mock-azure-data.json  # Azure resources and Entra ID
│       └── mock-k8s-data.json    # Kubernetes cluster with RBAC
├── localstack/                    # AWS service emulation (NEW)
│   └── init/
│       └── 01-setup-aws-resources.sh # LocalStack infrastructure setup
├── neo4j/                         # Graph database configuration and data
│   ├── init-complete.cypher       # Core attack scenario data
│   ├── phase2-scenarios.cypher    # Advanced attack scenarios
│   ├── mitre-integration.cypher   # MITRE ATT&CK technique mappings
│   └── cartography-scenarios.cypher # Discovery-based scenarios (NEW)
└── dashboard/                     # Interactive web interface (ENHANCED)
    ├── index.html                 # Main dashboard with asset discovery
    ├── app.js                     # Interactive analysis with 10 scenarios
    ├── cartography-service.js     # Asset discovery service integration (NEW)
    ├── style.css                  # Dashboard styling and UX
    └── Dockerfile
```

## 🗺️ Phase 3: Asset Discovery & Cartography Integration

### 🚀 NEW: Dynamic Asset Discovery Simulation

**Experience realistic cloud asset discovery workflows that demonstrate how security teams map complex cloud environments and identify hidden attack paths.**

#### 🔍 Asset Discovery Features

**Progressive Discovery Simulation:**
- **"Discover Infrastructure" Button:** Triggers realistic Cartography-style asset enumeration
- **7-Phase Discovery Process:** Foundation → Identity → Compute → Storage → Serverless → Relationships → Security Analysis
- **Real-time Progress Tracking:** Watch as assets and relationships are discovered over time
- **Educational Workflow:** Experience how automated tools reveal hidden infrastructure

**Multi-Cloud Mock Environment:**
- **AWS Services:** 50+ resources (EC2, IAM, S3, Lambda, API Gateway, VPC, Security Groups)
- **Azure Integration:** Virtual Machines, Storage Accounts, Key Vaults, Entra ID, Managed Identities
- **Kubernetes Cluster:** Pods, Services, RBAC, Secrets, Namespaces with realistic configurations
- **LocalStack Integration:** Full AWS service emulation for hands-on experience

**Enhanced Attack Scenarios:**

**🆕 Scenario 9: Real-World Asset Discovery Attack Path**
- Demonstrates how attackers use cloud service discovery (T1526) to identify overprivileged resources
- Shows automated account enumeration (T1087) and permission discovery (T1069)
- **Risk Level:** HIGH | **MITRE Techniques:** T1526, T1087, T1069, T1548, T1134

**🆕 Scenario 10: Cross-Cloud Infrastructure Attack via Asset Discovery**
- Reveals hidden cross-cloud trust relationships through automated discovery
- Demonstrates federated identity exploitation across cloud providers
- **Risk Level:** CRITICAL | **MITRE Techniques:** T1538, T1526, T1550.001, T1199, T1078

#### 🎯 How to Use Asset Discovery

**Step 1: Start the Lab**
```bash
docker-compose up -d
# Wait ~60 seconds for services to initialize
```

**Step 2: Access the Enhanced Dashboard**
- Open http://localhost:3000
- Navigate to the "🗺️ Asset Discovery" panel
- Click **"🔍 Discover Infrastructure"** to start simulation

**Step 3: Watch Progressive Discovery**
- **Phase 1:** Foundation Discovery (AWS accounts, regions)
- **Phase 2:** Identity Discovery (IAM users, roles, policies)
- **Phase 3:** Compute Discovery (EC2, VPC, security groups)
- **Phase 4:** Storage Discovery (S3 buckets, databases)
- **Phase 5:** Serverless Discovery (Lambda, API Gateway)
- **Phase 6:** Relationship Discovery (cross-service connections)
- **Phase 7:** Security Analysis (risk assessment)

**Step 4: Explore Discovery-Based Scenarios**
- New scenarios become available after discovery
- Run queries to see discovered assets and relationships
- Analyze attack paths that were previously hidden

#### 🔧 Discovery Simulation Scripts

**Manual Discovery Trigger:**
```bash
./scripts/start-discovery-simulation.sh
```

**Environment Reset:**
```bash
./scripts/reset-environment.sh
```

#### 📊 Discovery Analytics Queries

**View Discovered Assets:**
```cypher
MATCH (asset) 
WHERE asset.discovered_via_cartography = true
RETURN labels(asset)[0] as AssetType, 
       count(asset) as Count,
       min(asset.discovery_time) as FirstDiscovered
ORDER BY Count DESC
```

**Find Attack Paths Revealed by Discovery:**
```cypher
MATCH path = (start)-[*3..6]->(sensitive:SensitiveData)
WHERE start.discovered_via_cartography = true
  AND all(node in nodes(path) WHERE exists(node.discovered_via_cartography))
RETURN path, length(path) as AttackSteps
ORDER BY AttackSteps ASC
LIMIT 10
```

**Cross-Cloud Relationships:**
```cypher
MATCH (source)-[r*1..3]->(target)
WHERE source.discovered_via_cartography = true 
  AND target.discovered_via_cartography = true
  AND source.cloud_provider <> target.cloud_provider
RETURN source.cloud_provider as SourceCloud,
       target.cloud_provider as TargetCloud,
       [rel in r | type(rel)] as TrustMechanism
```

### 🎨 Advanced Visualization & Analytics
- Interactive asset discovery dashboard with real-time progress
- Before/after comparison of infrastructure visibility
- Discovery timeline and relationship emergence visualization
- Security risk analysis of discovered assets

### 🔧 Enterprise-Ready Architecture
- Cartography container integration with realistic mock data
- LocalStack AWS service emulation for hands-on learning
- Scalable architecture supporting 10-25 concurrent students
- Comprehensive reset and simulation management scripts

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