# 🎯 Tutorial: Introduction to Security Graphs

**Duration:** 30 minutes  
**Difficulty:** Beginner  
**Prerequisites:** None  

## 🎓 Learning Objectives

By the end of this tutorial, you will:
- Understand what security graphs are and why they matter
- Recognize basic graph components (nodes, edges, properties)
- Identify security relationships in cloud environments
- Complete your first basic security query

---

## 📖 What Are Security Graphs?

### Traditional Security Management
Imagine trying to understand your cloud security by looking at lists:
- **Users List:** Sarah, Mike, Emma, John...
- **Resources List:** Database1, S3Bucket2, Lambda3...
- **Permissions List:** Sarah→Read, Mike→Admin, Emma→Write...

**Problem:** You can't see the connections and attack paths!

### Security Graphs Approach
Security graphs visualize relationships:
```
[Sarah] --can-access--> [Database1] --contains--> [Customer PII]
   |                                                    ^
   |--assumes-role--> [AdminRole] --can-access-----------
```

**Advantage:** Attack paths become visible!

---

## 🏗️ Graph Components

### 1. **Nodes** (The "Things")
- **Users:** People who access systems
- **Resources:** Databases, files, services
- **Roles:** Permission sets
- **Services:** Applications, APIs

### 2. **Edges** (The "Relationships")
- **CAN_ACCESS:** User can reach resource
- **ASSUMES_ROLE:** User can escalate privileges
- **CONTAINS:** Resource holds data
- **TRUSTS:** Cross-system relationships

### 3. **Properties** (The "Details")
- User properties: `name`, `access_level`, `department`
- Resource properties: `contains_pii`, `classification`, `owner`

---

## 🎯 Interactive Exercise 1: Spot the Security Risk

Look at this scenario:
```
[Developer] --can-access--> [DevDatabase]
[Developer] --assumes-role--> [AdminRole] --can-access--> [ProductionDB]
```

**Question:** What's the security risk here?

<details>
<summary>Click for Answer</summary>

**Risk:** Developer can escalate to admin privileges and access production data!

**Why it's dangerous:**
- Violates principle of least privilege
- Creates insider threat risk
- Bypasses production access controls

**Mitigation:** Remove admin role access or add approval workflow
</details>

---

## 🔍 Your First Security Query

Let's find users who can access sensitive data:

```cypher
MATCH (user:User)-[access]->(resource)
WHERE resource.contains_pii = true
RETURN user.name, resource.name, type(access)
```

**Breaking it down:**
- `MATCH`: Find patterns in the graph
- `(user:User)`: Find nodes labeled "User"
- `-[access]->`: Follow any outgoing relationship
- `(resource)`: To any target node
- `WHERE`: Filter for sensitive resources
- `RETURN`: Show the results

---

## 🎮 Hands-On Practice

### Exercise 2: Build Your Own Query

**Scenario:** Find all administrators and what they can access.

**Your Task:** Complete this query:
```cypher
MATCH (user:User)-[access]->(resource)
WHERE user.access_level = '???'
RETURN ???
```

<details>
<summary>Solution</summary>

```cypher
MATCH (user:User)-[access]->(resource)
WHERE user.access_level = 'administrator'
RETURN user.name, resource.name, type(access)
```
</details>

### Exercise 3: Thinking Like an Attacker

**Question:** If you were an attacker who compromised a developer account, what would you look for?

Think about:
- What resources can developers access?
- Can they escalate privileges?
- What sensitive data is reachable?

---

## 🎯 Knowledge Check

### Question 1
What makes security graphs better than traditional lists?
- a) They store more data
- b) They show relationships and attack paths
- c) They are faster to query

### Question 2
In the relationship `(User)-[:CAN_ACCESS]->(Database)`, what are the components?
- a) User=node, CAN_ACCESS=property, Database=edge
- b) User=edge, CAN_ACCESS=node, Database=property
- c) User=node, CAN_ACCESS=edge, Database=node

### Question 3
Why is the query pattern `(user)-[*1..3]->(target)` useful for security?
- a) It finds direct connections only
- b) It finds attack paths up to 3 steps long
- c) It counts the number of users

<details>
<summary>Answers</summary>

1. **b** - Relationships and attack paths are the key advantage
2. **c** - Nodes are the entities, edges are the relationships
3. **b** - Multi-hop patterns find indirect attack paths
</details>

---

## 🎊 Tutorial Complete!

### What You've Learned:
✅ Security graphs visualize attack paths  
✅ Nodes, edges, and properties represent security components  
✅ Cypher queries find security patterns  
✅ Graph thinking helps identify risks  

### Next Steps:
- **Tutorial 2:** Basic Attack Path Analysis
- **Practice:** Try the interactive scenarios in the dashboard
- **Explore:** Use Neo4j Browser to experiment with queries

### Key Takeaway:
**Security is about relationships** - graphs make hidden connections visible!

---

**🎓 Tutorial Progress: 1/15 Complete**  
**⭐ Achievement Unlocked: Graph Security Basics**