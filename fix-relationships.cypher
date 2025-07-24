// Fix Missing Relationships - Add Direct Attack Paths
// Run this in Neo4j Browser or via command line

// First, let's see what we have
MATCH (u:User) WHERE u.name = 'Sarah Chen' 
MATCH (s:Service) WHERE s.name = 'company-sensitive-data'
RETURN u.name as User, s.name as Service;

// Add missing direct relationships for Sarah Chen (AWS developer)
MATCH (dev_user:User {name: 'Sarah Chen'})
MATCH (s3_bucket:Service {name: 'company-sensitive-data'})
MERGE (dev_user)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Developer can access via role escalation',
  created: datetime()
}]->(s3_bucket);

// Add relationship to admin role if it exists
MATCH (dev_user:User {name: 'Sarah Chen'})
MATCH (admin_role:Role {name: 'AdminRole'})
MERGE (dev_user)-[:ASSUMES_ROLE {
  method: 'sts:AssumeRole',
  conditions: 'MFA not required',
  created: datetime()
}]->(admin_role);

// Add role to service relationship
MATCH (admin_role:Role {name: 'AdminRole'})
MATCH (s3_bucket:Service {name: 'company-sensitive-data'})
MERGE (admin_role)-[:CAN_ACCESS {
  permissions: ['s3:GetObject', 's3:ListBucket'],
  granted: datetime()
}]->(s3_bucket);

// Add Emma Watson cross-cloud access
MATCH (azure_user:User {name: 'Emma Watson'})
MATCH (s3_bucket:Service {name: 'company-sensitive-data'})
MERGE (azure_user)-[:CAN_ACCESS {
  method: 'Through CI/CD pipeline',
  description: 'Cross-cloud access via GitHub Actions',
  created: datetime()
}]->(s3_bucket);

// Verify the fixes worked
MATCH (u:User)-[r:CAN_ACCESS]->(s:Service)
RETURN u.name as User, type(r) as Relationship, s.name as Service, r.method as Method;

// Return success message
RETURN "Relationships fixed! Try your queries again." as Status;