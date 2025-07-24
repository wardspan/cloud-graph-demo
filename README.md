# 🛡️ Cloud Threat Graph Lab - Phase 1

> **Advanced Security Simulation & Attack Path Analysis**  
> A comprehensive Dockerized lab that simulates realistic cloud attack paths using Neo4j with MITRE ATT&CK integration.

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

## 📋 What's Included (Phase 1)

### 🎯 Attack Scenarios
1. **AWS Privilege Escalation** - Developer user → role assumption → admin access
2. **Cross-Cloud Attack Chain** - Azure AD → CI/CD → AWS role → S3 access  
3. **Kubernetes RBAC Escalation** - Pod → ServiceAccount → ClusterRole escalation
4. **Supply Chain Container Escape** - Compromised package → host compromise

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

### 3. Explore Attack Scenarios

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
./load-data.sh
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
# Wait 2 minutes, then run: ./load-data.sh
```

## 📊 Lab Statistics

- **Nodes**: 68 (Users, Roles, Services, Pods, Images, Hosts, etc.)
- **Relationships**: 30+ (Complete attack paths and privilege escalations)
- **MITRE Techniques**: 12 (T1078, T1548, T1134, T1195, etc.)
- **Scenarios**: 4 realistic attack chains with full connectivity
- **Attack Paths**: Working user→service relationships for all scenarios

### ✅ **Verified Working Queries:**
- AWS Privilege Escalation paths ✅
- Cross-Cloud Azure→AWS paths ✅  
- Kubernetes RBAC escalations ✅
- Supply Chain container escapes ✅

### 🎨 **Enhanced Dashboard Features:**
- **Smart Overview Panel:** Click scenarios to see detailed analysis, MITRE techniques, and risk assessment
- **Clean Query Interface:** Simplified execution with direct Neo4j browser links
- **MITRE ATT&CK Integration:** Each scenario mapped to specific techniques
- **Risk Assessment:** Visual risk levels (HIGH/CRITICAL) with attack step breakdown

## 🔮 Future Phases

### Phase 2: Enhanced Data & MITRE
- Expand to 6-7 attack scenarios
- Enhanced MITRE ATT&CK technique mapping
- Mock Cartography data integration
- Advanced Cypher queries

### Phase 3: Cartography Integration  
- Add Cartography container
- Mock cloud API responses
- Asset discovery simulation
- Dynamic graph population

### Phase 4: Interactive Components
- React/Vue dashboard
- Jupyter notebooks for analysis
- Attack simulation engine
- Advanced graph visualization

### Phase 5: Advanced Features
- Metrics collection and analytics
- Export capabilities (JSON, CSV, GraphML)
- Community sharing features
- Integration with security tools

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

**🎯 Phase 1 Success**: Users can run `docker-compose up`, access Neo4j at localhost:7474, explore 4 attack scenarios, run Cypher queries, and view the simple dashboard. Foundation established for advanced features in future phases!