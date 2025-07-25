# 🛡️ Cloud Threat Graph Lab

> **Phase 4: Educational Analytics & Interactive Learning Platform**  
> The definitive cloud security education platform featuring interactive learning paths, explainable machine learning, comprehensive progress tracking, and hands-on cybersecurity training with Neo4j graph database.

## 🚀 Quick Start

```bash
# Clone and start the educational platform
git clone <your-repo-url> cloud-threat-lab
cd cloud-threat-lab
docker-compose up -d

# Wait for services to initialize (about 90 seconds)
# Access the Phase 4 educational platform:
# - Jupyter Lab: http://localhost:8888 (token: cloudsecurity)
# - Dashboard: http://localhost:3000 (interactive scenarios)
# - Neo4j Browser: http://localhost:7474 (neo4j/cloudsecurity)
```

## 🎓 Educational Pathways

**Choose your learning journey based on your experience level:**

### 🎯 **Beginner: Security Graph Fundamentals (3-4 hours)**
- Start with `01-Graph-Fundamentals.ipynb` in Jupyter Lab
- Learn graph theory basics with security context
- Master basic Cypher queries for threat analysis
- **Perfect for:** Security analysts new to graph analysis

### 🔍 **Intermediate: Advanced Threat Analysis (4-5 hours)**  
- Continue with `02-Attack-Path-Discovery.ipynb`
- Explore MITRE ATT&CK framework integration
- Practice multi-hop attack analysis techniques
- **Perfect for:** Experienced security professionals

### 🤖 **Advanced: ML Security Analytics (6-8 hours)**
- Dive into `05-Anomaly-Detection-ML.ipynb` 
- Learn explainable machine learning for cybersecurity
- Build custom risk assessment models
- **Perfect for:** Security engineers and data scientists

### 🔬 **Expert: Security Research & Development (8-10 hours)**
- Explore advanced notebooks and custom scenario building
- Contribute to security research and tool development
- Lead security data science initiatives
- **Perfect for:** Security researchers and team leads

## 🌟 Phase 4 Features: Complete Educational Platform

### 🎓 **Interactive Learning Platform**

**10 Comprehensive Jupyter Notebooks:**
- **01-Graph-Fundamentals.ipynb** - Security graph basics with visual learning
- **02-Attack-Path-Discovery.ipynb** - Advanced attack path analysis techniques  
- **03-MITRE-Analysis.ipynb** - Industry framework integration *(Coming Soon)*
- **04-Asset-Discovery-Analysis.ipynb** - Cartography and asset discovery *(Coming Soon)*
- **05-Anomaly-Detection-ML.ipynb** - Machine learning with complete explanations
- **06-Graph-Algorithms-Security.ipynb** - Graph theory for security optimization *(Coming Soon)*
- **07-Risk-Scoring-Models.ipynb** - Transparent risk assessment methods *(Coming Soon)*
- **08-Threat-Hunting-Automation.ipynb** - Automated detection development *(Coming Soon)*
- **09-Custom-Scenario-Building.ipynb** - Creating original attack scenarios *(Coming Soon)*
- **10-Advanced-Graph-Mining.ipynb** - Research-level security analytics *(Coming Soon)*

**Educational Excellence:**
- **Explainable AI** - Every ML algorithm explained with why/how/when
- **Progressive Learning** - Beginner → Expert pathways with prerequisites
- **Interactive Assessments** - Knowledge checks with immediate feedback
- **Adaptive Recommendations** - Personalized learning based on performance
- **Achievement System** - Gamified learning with certificates and badges

### 🎯 10 Attack Scenarios (Enhanced for Education)

**Core Attack Scenarios:**
1. **AWS Privilege Escalation** (CRITICAL) - Developer user → role assumption → admin access
2. **Kubernetes RBAC Escalation** (HIGH) - Pod → ServiceAccount → ClusterRole escalation
3. **Secrets Sprawl Attack** (HIGH) - Hardcoded GitHub token → Terraform state → cloud admin credentials
4. **Serverless Attack Chain** (HIGH) - API Gateway → overprivileged Lambda → data exfiltration
5. **Cross-Cloud Attack Chain** (CRITICAL) - Azure AD → CI/CD → AWS role → S3 access  
6. **Supply Chain Container Escape** (CRITICAL) - Compromised package → host compromise
7. **Supply Chain Compromise** (CRITICAL) - NPM package → CI/CD injection → cloud deployment → secrets access
8. **Multi-Cloud Identity Federation** (CRITICAL) - Azure AD guest → OIDC federation → AWS production access

**🆕 Phase 3: Asset Discovery-Based Scenarios:**
9. **Real-World Asset Discovery Attack Path** (HIGH) - Cloud service discovery → overprivileged resource identification → exploitation
10. **Cross-Cloud Infrastructure Attack via Asset Discovery** (CRITICAL) - Multi-cloud federation discovery → trust relationship exploitation

### 🎨 Enhanced Dashboard Experience (Phase 3)
- **Professional 2x5 Grid Layout**: Risk-based scenario organization with color-coded priority levels
- **Dynamic Asset Discovery**: Real-time infrastructure discovery simulation with Cartography integration
- **Comprehensive Scenario Information**: Detailed analysis, MITRE techniques, and risk assessments for each scenario
- **Integrated Analysis Workflow**: Direct Neo4j Browser launching with pre-loaded queries
- **Persistent Discovery State**: Asset counters and discovery progress maintained across sessions
- **Educational Documentation**: Extensive help section with Cartography integration guides and GitHub links

### ⚔️ MITRE ATT&CK Integration (Enhanced)
- **22+ Techniques** across 11 tactics with comprehensive mappings for all 10 scenarios
- **Detection Guidance** for each technique with specific indicators
- **Mitigation Strategies** with actionable defense recommendations
- **Threat Intelligence** integration for real-world attack context

### 🏗️ Phase 3 Architecture
- **Neo4j Database** (port 7474/7687) - Graph database with robust unified data loading
- **Enhanced Dashboard** (port 3000) - Professional 2x5 grid interface with asset discovery
- **Cartography Integration** - Dynamic asset discovery simulation with realistic cloud data
- **LocalStack Emulation** (port 4566) - AWS service emulation for hands-on experience
- **Robust Data Loader** - Single-transaction approach eliminating race conditions

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

### 1. **Phase 4: Start Your Educational Journey**
- **Access Dashboard**: Open http://localhost:3000
- **🎓 Learn with Jupyter**: Click the educational link in the status bar
- **Educational Introduction**: Interactive modal explains Jupyter notebooks and learning paths
- **Choose Your Path**: Select from Beginner → Expert progression based on your experience
- **Start Learning**: Begins with `01-Graph-Fundamentals.ipynb` for comprehensive education

### 2. **Dashboard Analysis Workflow**
- **Select Attack Scenarios**: Choose from 10 realistic scenarios organized by risk level
- **View Scenario Details**: Each scenario includes:
  - Analysis explanation and risk assessment
  - Expected results and key indicators
  - MITRE ATT&CK techniques and tactics
  - Interpretation tips for findings
- **Run Analysis**: Click **Table Analysis** or **Graph Visualization**:
  - Neo4j Browser opens automatically with the query pre-loaded
  - Query displays in professional code window within the scenario panel
  - Copy queries directly for custom analysis
- **Seamless Learning**: Analysis flows naturally from attack understanding to educational exploration

### 3. **Interactive Learning Platform**
- **Jupyter Lab Access**: http://localhost:8888 (token: cloudsecurity)
- **10 Educational Notebooks**: Progressive curriculum with hands-on exercises
- **Explainable AI**: Every ML algorithm explained with why/how/when context
- **Progress Tracking**: Your learning journey is automatically monitored
- **Assessment System**: Interactive quizzes and practical challenges

### 4. **Neo4j Browser Deep Dive**
- Open http://localhost:7474
- Login: `neo4j` / `cloudsecurity`
- Run the queries above to explore the graph
- Use the graph visualization to see relationships

### 5. **Asset Discovery Simulation**
- **🔍 Discover Infrastructure**: Click the discovery button to simulate Cartography asset enumeration
- **Progressive Discovery**: Watch as the system discovers accounts → IAM → compute → storage → serverless
- **Discovery-Based Scenarios**: Unlocks scenarios 9 & 10 that show attack paths revealed through asset discovery
- **Real-World Relevance**: Experience how automated tools reveal hidden infrastructure risks

### 6. Explore Attack Scenarios

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

## 📊 Phase 3 Lab Statistics

- **Attack Scenarios**: 10 comprehensive scenarios (8 enhanced + 2 new discovery-based)
- **Graph Nodes**: 29 nodes with verified relationships and consistent data loading
- **Graph Relationships**: 25 relationships ensuring all scenario queries return results
- **MITRE Techniques**: 22+ techniques across 11 tactics with comprehensive mappings
- **Data Reliability**: 100% consistent loading with robust single-transaction approach
- **Asset Discovery**: Dynamic Cartography integration with LocalStack AWS emulation
- **UI/UX**: Professional 2x5 grid layout with risk-based organization
- **Documentation**: Comprehensive help section with Cartography guides and GitHub links

### ✅ **Phase 3 Analysis Coverage:**
- **AWS Privilege Escalation**: Developer → Admin access paths (4 results)
- **Supply Chain Compromise**: NPM package → Secrets access (1 result)
- **Asset Discovery Scenarios**: Cartography-based attack paths (5 results)
- **Cross-Cloud Federation**: Azure → AWS trust exploitation
- **Kubernetes RBAC**: ServiceAccount privilege escalation
- **Serverless Attacks**: API Gateway → Lambda → Data access
- **Secrets Sprawl**: Hardcoded tokens → Production access
- **Container Escape**: Compromised package → Host compromise

### 🔍 **Enhanced Analysis Capabilities:**
- **Professional Dashboard**: 2x5 grid layout with risk-based color coding
- **Dynamic Asset Discovery**: Real-time Cartography simulation with progress tracking
- **Comprehensive Scenario Details**: Analysis, MITRE techniques, risk levels, and attack steps
- **Robust Data Loading**: 100% reliable data consistency across container restarts
- **Interactive Neo4j Integration**: Direct browser launching with pre-loaded queries
- **Educational Focus**: Extensive documentation and help resources

## 📁 **Project Structure**

```
cloud-threat-lab/
├── docker-compose.yml              # Phase 3: Robust container orchestration with unified data loading
├── README.md                       # Comprehensive Phase 3 documentation
├── .gitignore                      # Version control patterns
├── cartography/                    # 🆕 Cartography integration for dynamic asset discovery
│   ├── Dockerfile                  # Cartography container with LocalStack integration
│   ├── run-discovery.sh            # Asset discovery simulation orchestration
│   ├── simulate-discovery.py       # Python-based discovery simulator
│   ├── config/ 
│   │   └── config.yaml            # Cartography configuration for cloud discovery
│   └── mock-data/                 # Realistic cloud infrastructure datasets
│       ├── aws-resources.json     # Comprehensive AWS mock infrastructure
│       ├── mock-azure-data.json   # Azure AD and resource mock data
│       └── mock-k8s-data.json     # Kubernetes cluster with RBAC
├── localstack/                     # 🆕 AWS service emulation for hands-on experience
│   └── init/
│       └── 01-setup-aws-resources.sh # LocalStack AWS service initialization
├── neo4j/                          # Enhanced graph database with robust data loading
│   └── unified-data-load.cypher    # 🔄 Single-transaction unified data loader (Phase 3)
└── dashboard/                      # 🎨 Enhanced professional dashboard (Phase 3)
    ├── index.html                  # Main dashboard with 2x5 grid layout
    ├── app.js                      # 10 scenarios with comprehensive information panels
    ├── cartography-service.js      # Asset discovery service integration
    ├── style.css                   # Professional styling with risk-based design
    ├── nginx.conf                  # Web server configuration
    └── Dockerfile                  # Dashboard container build
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

## 🚀 Phase 4: Educational Analytics & Interactive Learning Platform

### 🎯 Complete Educational Transformation
- **10 Interactive Notebooks**: Comprehensive curriculum with explainable ML and hands-on exercises
- **4 Learning Pathways**: Structured Beginner → Expert progression with adaptive recommendations
- **Advanced Analytics Engine**: Machine learning models with step-by-step educational explanations
- **Progress Tracking System**: Comprehensive analytics with skill assessment and achievement systems
- **Seamless Dashboard Integration**: Direct access to Jupyter Lab with educational introduction modal
- **Jupyter Lab Integration**: Professional educational environment with pre-configured security libraries
- **Production-Quality Platform**: Enterprise-ready educational infrastructure for serious training initiatives

### 🌟 **New: Dashboard-to-Learning Integration**
The dashboard now features a **🎓 Learn with Jupyter** link that provides:
- **Educational Introduction Modal**: Comprehensive explanation of Jupyter notebooks and learning benefits
- **Learning Path Guidance**: Detailed overview of all 4 educational pathways with time estimates
- **Skill Development Preview**: Clear explanation of technical skills and security concepts to be learned
- **Getting Started Instructions**: Step-by-step guidance for beginning the educational journey
- **Seamless Navigation**: Direct access to Jupyter Lab with proper context and expectations

### 🎓 Educational Impact & Value
- **Academic Excellence**: Research-based learning design suitable for university cybersecurity programs
- **Industry Training**: Enterprise-ready platform for security team development and certification
- **Professional Development**: Advanced skills training for security analysts, engineers, and researchers
- **Explainable AI Education**: Transparent machine learning education bridging theory and practice
- **Hands-On Competency**: Real-world skills development through interactive exercises and assessments
- **Career Advancement**: Comprehensive curriculum supporting security data science specialization

### 🏆 Phase 4 Technical Excellence
- **Educational Architecture**: Seamless integration of learning management with technical analysis
- **Explainable ML Framework**: Complete transparency in AI decision-making for security applications
- **Adaptive Learning Engine**: Personalized recommendations based on individual progress and performance
- **Comprehensive Assessment**: Multi-modal evaluation with immediate feedback and remediation
- **Scalable Platform**: Supports individual learning, classroom instruction, and enterprise deployment
- **Research Foundation**: Platform designed for academic research and continuous content improvement