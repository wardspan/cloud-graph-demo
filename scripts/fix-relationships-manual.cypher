// Manual Relationship Creation - Test This Step by Step

// First, verify the nodes exist
MATCH (sarah:User {name: 'Sarah Chen'})
MATCH (emma:User {name: 'Emma Watson'}) 
MATCH (s3:Service {name: 'company-sensitive-data'})
RETURN sarah.name as SarahExists, emma.name as EmmaExists, s3.name as S3Exists;

// Create basic relationships one by one
MATCH (sarah:User {name: 'Sarah Chen'})
MATCH (s3:Service {name: 'company-sensitive-data'})
MERGE (sarah)-[:CAN_ACCESS {
  method: 'Through assumed roles',
  description: 'Developer access via role escalation',
  created: datetime()
}]->(s3);

MATCH (emma:User {name: 'Emma Watson'})
MATCH (s3:Service {name: 'company-sensitive-data'})
MERGE (emma)-[:CAN_ACCESS {
  method: 'Through CI/CD pipeline',
  description: 'Cross-cloud access via GitHub Actions',
  created: datetime()
}]->(s3);

// Create role relationships if roles exist
MATCH (sarah:User {name: 'Sarah Chen'})
MATCH (admin_role:Role {name: 'AdminRole'})
MERGE (sarah)-[:ASSUMES_ROLE {
  method: 'sts:AssumeRole',
  created: datetime()
}]->(admin_role);

MATCH (admin_role:Role {name: 'AdminRole'})
MATCH (s3:Service {name: 'company-sensitive-data'})
MERGE (admin_role)-[:CAN_ACCESS {
  permissions: ['s3:GetObject', 's3:ListBucket'],
  created: datetime()
}]->(s3);

// Verify the relationships were created
MATCH (u:User)-[r]->(target)
RETURN u.name as User, type(r) as Relationship, 
       CASE 
         WHEN target:Service THEN target.name 
         WHEN target:Role THEN target.name 
         ELSE 'Unknown'
       END as Target
ORDER BY User, Relationship;

// Final test of the working query
MATCH (u:User)-[r:CAN_ACCESS]->(s:Service)
RETURN u.name as User, s.name as Service, r.method as Method
ORDER BY User;

RETURN "Manual relationships created successfully!" as Status;