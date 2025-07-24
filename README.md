# 🛡️ Cloud Threat Graph Lab - Phase 2: Enhanced Data & MITRE Integration

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

## 📋 What's New in Phase 2 ✨

### 🎯 8 Attack Scenarios (Doubled from Phase 1)

#### Phase 1 Foundation
1. **AWS Privilege Escalation** - Developer user → role assumption → admin access
2. **Cross-Cloud Attack Chain** - Azure AD → CI/CD → AWS role → S3 access  
3. **Kubernetes RBAC Escalation** - Pod → ServiceAccount → ClusterRole escalation
4. **Supply Chain Container Escape** - Compromised package → host compromise

#### Phase 2 Enhanced Scenarios
5. **Supply Chain Compromise** - NPM package → CI/CD injection → cloud deployment → secrets access
6. **Secrets Sprawl Attack** - Hardcoded GitHub token → Terraform state → cloud admin credentials
7. **Serverless Attack Chain** - API Gateway → overprivileged Lambda → data exfiltration
8. **Multi-Cloud Identity Federation** - Azure AD guest → OIDC federation → AWS production access

### 🎨 Enhanced Dashboard UX
- **Integrated Analysis**: Query buttons built directly into each scenario panel
- **Auto-Open Neo4j**: Clicking analysis buttons automatically opens Neo4j Browser
- **Inline Query Display**: See queries in bash-style windows within scenario information
- **Table & Graph Views**: Separate analysis options for tabular data and graph visualization
- **No More Disconnected UI**: Analysis is seamlessly connected to each attack scenario

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

### 3. New Dashboard Experience

The Phase 2 dashboard provides an integrated user experience:

1. **Click Attack Scenarios**: Select any of the 8 attack scenarios from the left panel
2. **Scenario Information**: View detailed analysis including:
   - What the query analyzes
   - Expected results and risk assessment  
   - MITRE ATT&CK techniques used
   - Analysis tips for interpretation
3. **Integrated Analysis**: Click **Table Analysis** or **Graph Visualization** buttons:
   - Query automatically runs in Neo4j Browser
   - Query appears in bash-style window within scenario information
   - Copy query directly from the scenario panel
4. **No More UI Confusion**: Analysis is directly connected to each attack scenario

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

## 📊 Lab Statistics (Phase 2)

- **Nodes**: 215+ (Users, Roles, Services, Pods, Images, Hosts, MITRE Techniques, etc.)
- **Relationships**: 55+ (Complete attack paths and privilege escalations)
- **MITRE Techniques**: 25 across 11 tactics (T1078, T1548, T1134, T1195, T1190, T1530, etc.)
- **Scenarios**: 8 realistic attack chains with working analysis queries
- **Mock Data**: AWS, Azure, and Kubernetes data ready for Cartography integration
- **Attack Paths**: Verified working user→service relationships for all scenarios

### ✅ **Verified Working Analysis (All 8 Scenarios):**
- AWS Privilege Escalation paths ✅ (Table & Graph views)
- Cross-Cloud Azure→AWS paths ✅ (Table & Graph views)
- Kubernetes RBAC escalations ✅ (Table & Graph views)
- Supply Chain container escapes ✅ (Table & Graph views)
- Supply Chain CI/CD compromise ✅ (Table & Graph views)
- Secrets sprawl and exposure ✅ (Table & Graph views)
- Serverless attack chains ✅ (Table & Graph views)
- Multi-cloud federation attacks ✅ (Table & Graph views)

### 🎨 **Phase 2 Dashboard Revolution:**
- **Integrated UX**: Analysis buttons built into each scenario panel
- **Auto-Open Neo4j**: Queries automatically run in Neo4j Browser
- **Bash-Style Query Display**: Copy queries directly from scenario information
- **Table & Graph Analysis**: Separate options for different visualization needs
- **No UI Confusion**: Attack scenarios seamlessly connected to analysis
- **8 Working Scenarios**: All scenarios return actual data, not empty results
- **MITRE Integration**: 25 techniques with detection and mitigation guidance

## 📁 **Project Structure**

```
cloud-threat-lab/
├── docker-compose.yml              # Enhanced orchestration for Phase 2
├── README.md                       # This file
├── .gitignore                      # Comprehensive ignore patterns
├── scripts/                        # All executable scripts and utilities
│   ├── load-data.sh               # Manual data loading
│   ├── load-phase2-data.sh        # Phase 2 data loader
│   ├── quick-fix.sh               # Fix missing relationships
│   └── reload-fresh-data.sh       # Complete data reload
├── docs/                          # Enhanced documentation
│   ├── attack-scenarios-enhanced.md # Complete scenario documentation
│   ├── mitre-integration-guide.md   # MITRE ATT&CK integration guide
│   ├── WORKING_QUERIES.md          # Query examples that work
│   └── DEBUG_QUERIES.md            # Debugging help
├── cartography/                   # Mock data for Phase 3 preparation
│   ├── mock-aws-data.json         # Realistic AWS asset data
│   ├── mock-azure-data.json       # Azure resource data
│   └── mock-k8s-data.json         # Kubernetes cluster data
├── neo4j/                         # Neo4j configuration and data
│   ├── init-complete.cypher       # Phase 1 foundation data
│   ├── phase2-scenarios.cypher    # Phase 2 enhanced scenarios
│   └── mitre-integration.cypher   # MITRE ATT&CK techniques
└── dashboard/                     # Enhanced web dashboard
    ├── index.html                 # Phase 2 dashboard with 8 scenarios
    ├── app.js                     # Enhanced JavaScript with MITRE integration
    ├── style.css                  # Updated styling with phase badges
    └── Dockerfile
```

## 🔮 Future Phases

### ✅ Phase 2: Enhanced Data & MITRE (COMPLETED)
- ✅ 8 attack scenarios (expanded from 4)
- ✅ 25 MITRE ATT&CK techniques with full integration
- ✅ Mock Cartography data preparation (AWS, Azure, Kubernetes)
- ✅ Enhanced dashboard with phase indicators and MITRE overlay
- ✅ Comprehensive documentation and integration guides

### Phase 3: Cartography Integration  
- Add Cartography container for dynamic asset discovery
- Mock cloud API responses for realistic data ingestion
- Asset discovery simulation workflow  
- Dynamic graph population from "live" cloud environments
- Real-time graph updates as "assets are discovered"

### Phase 4: Interactive Components
- Modern React/Vue dashboard with advanced visualization
- Jupyter notebooks for threat research and analysis
- Attack simulation engine with automated progression
- Advanced graph visualization with D3.js or vis.js
- Query builder interface for non-Cypher users

### Phase 5: Advanced Features
- Metrics collection and analytics dashboard
- Export capabilities (JSON, CSV, GraphML, MITRE Navigator)
- Community sharing features and scenario marketplace  
- Integration with security tools (SIEM, SOAR, EDR)
- Automated red team scenario generation

## 🛡️ Security Notes

- **No real cloud credentials required** - This is a simulation using fake data
- **Defensive focus** - Designed for security analysis and education
- **Local environment** - All data stays on your machine
- **Educational purpose** - For learning cloud security concepts

## 🤝 Contributing

Phase 1 provides the foundation. Future contributions welcome for:
- Additional attack scenarios
- Enhanced MITRE mappings  
- New visualization features
- Documentation improvements

## 📄 License

MIT License - See LICENSE file for details.

---

## 🆚 Phase 1 vs Phase 2 Comparison

| Feature | Phase 1 (Foundation) | Phase 2 (Enhanced) |
|---------|---------------------|-------------------|
| **Attack Scenarios** | 4 scenarios | 8 scenarios |
| **Graph Nodes** | 68 nodes | 118+ nodes |
| **Relationships** | 30+ relationships | 55+ relationships |
| **MITRE Techniques** | 12 techniques | 25 techniques across 11 tactics |
| **Dashboard Queries** | 6 query buttons | 9 query buttons |
| **Phase Indicators** | ❌ | ✅ Phase badges on scenarios |
| **MITRE Integration** | Basic technique lists | Full detection & mitigation guidance |
| **Mock Data** | ❌ | ✅ AWS, Azure, K8s data for Phase 3 |
| **Documentation** | Basic README | Comprehensive scenario & MITRE guides |
| **Data Loading** | Single script | Multi-phase loader with verification |

**🎯 Phase 2 Success**: Users can explore 8 sophisticated attack scenarios with full MITRE ATT&CK integration, enhanced dashboard with phase indicators, comprehensive documentation, and mock data foundation ready for Cartography integration in Phase 3!