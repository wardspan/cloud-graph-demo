#!/usr/bin/env python3
"""
Cartography Asset Discovery Simulation
Simulates realistic cloud asset discovery by progressively populating Neo4j graph
"""

import json
import time
import random
from datetime import datetime, timedelta
from neo4j import GraphDatabase
import sys

# Neo4j connection
NEO4J_URI = "bolt://neo4j:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "cloudsecurity"

class AssetDiscoverySimulator:
    def __init__(self):
        self.driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
        self.discovery_start = datetime.now()
        
    def close(self):
        self.driver.close()
    
    def run_discovery_simulation(self):
        """Main discovery simulation workflow"""
        print("🔍 Starting Cartography-style asset discovery simulation...")
        print("=" * 60)
        
        # Phase 1: AWS Account and Region Discovery
        print("📍 Phase 1: Discovering AWS accounts and regions...")
        self.discover_aws_foundation()
        time.sleep(2)
        
        # Phase 2: IAM Infrastructure Discovery
        print("🔐 Phase 2: Discovering IAM users, roles, and policies...")
        self.discover_iam_infrastructure()
        time.sleep(3)
        
        # Phase 3: Compute and Network Discovery
        print("💻 Phase 3: Discovering EC2 instances and networking...")
        self.discover_compute_network()
        time.sleep(2)
        
        # Phase 4: Storage and Database Discovery
        print("🗄️ Phase 4: Discovering storage and database resources...")
        self.discover_storage_databases()
        time.sleep(2)
        
        # Phase 5: Serverless and API Discovery
        print("⚡ Phase 5: Discovering Lambda functions and API Gateways...")
        self.discover_serverless_apis()
        time.sleep(2)
        
        # Phase 6: Cross-Service Relationship Discovery
        print("🔗 Phase 6: Discovering cross-service relationships...")
        self.discover_relationships()
        time.sleep(2)
        
        # Phase 7: Security Analysis
        print("🛡️ Phase 7: Analyzing security configurations...")
        self.analyze_security_posture()
        
        print("=" * 60)
        print("✅ Asset discovery simulation complete!")
        self.print_discovery_summary()
    
    def discover_aws_foundation(self):
        """Discover AWS accounts and regions"""
        with self.driver.session() as session:
            # Discover AWS Account
            session.run("""
                MERGE (account:AWSAccount {
                    id: '123456789012',
                    name: 'production-account',
                    arn: 'arn:aws:organizations::123456789012:account/o-abc123defg/123456789012',
                    discovered_via_cartography: true,
                    discovery_time: datetime(),
                    cartography_lastupdated: datetime()
                })
            """)
            
            # Discover Regions
            regions = ['us-east-1', 'us-west-2', 'eu-west-1']
            for region in regions:
                session.run("""
                    MERGE (region:AWSRegion {
                        name: $region,
                        discovered_via_cartography: true,
                        discovery_time: datetime(),
                        cartography_lastupdated: datetime()
                    })
                    WITH region
                    MATCH (account:AWSAccount {id: '123456789012'})
                    MERGE (account)-[:CONTAINS_REGION]->(region)
                """, region=region)
            
            print("   ✅ Discovered 1 AWS account and 3 regions")
    
    def discover_iam_infrastructure(self):
        """Discover IAM users, roles, groups, and policies"""
        with self.driver.session() as session:
            # IAM Users
            iam_users = [
                {
                    'username': 'sarah.chen',
                    'userid': 'AIDACKCEVSQ6C2EXAMPLE',
                    'arn': 'arn:aws:iam::123456789012:user/sarah.chen',
                    'access_level': 'developer',
                    'mfa_enabled': True,
                    'last_activity': '2024-01-15'
                },
                {
                    'username': 'admin-service',
                    'userid': 'AIDACKCEVSQ6C3EXAMPLE',
                    'arn': 'arn:aws:iam::123456789012:user/admin-service',
                    'access_level': 'admin',
                    'mfa_enabled': False,
                    'last_activity': '2024-01-20'
                },
                {
                    'username': 'contractor.external',
                    'userid': 'AIDACKCEVSQ6C4EXAMPLE',
                    'arn': 'arn:aws:iam::123456789012:user/contractor.external',
                    'access_level': 'contractor',
                    'mfa_enabled': False,
                    'last_activity': '2024-01-10'
                }
            ]
            
            for user in iam_users:
                session.run("""
                    MERGE (user:IAMUser {
                        username: $username,
                        userid: $userid,
                        arn: $arn,
                        access_level: $access_level,
                        mfa_enabled: $mfa_enabled,
                        last_activity: $last_activity,
                        discovered_via_cartography: true,
                        discovery_time: datetime(),
                        cartography_lastupdated: datetime()
                    })
                    WITH user
                    MATCH (account:AWSAccount {id: '123456789012'})
                    MERGE (account)-[:CONTAINS_USER]->(user)
                """, **user)
            
            # IAM Roles
            iam_roles = [
                {
                    'name': 'EC2AdminRole',
                    'arn': 'arn:aws:iam::123456789012:role/EC2AdminRole',
                    'trust_policy': 'ec2.amazonaws.com',
                    'max_session_duration': 3600,
                    'privilege_level': 'admin'
                },
                {
                    'name': 'LambdaExecutionRole',
                    'arn': 'arn:aws:iam::123456789012:role/LambdaExecutionRole',
                    'trust_policy': 'lambda.amazonaws.com',
                    'max_session_duration': 3600,
                    'privilege_level': 'service'
                },
                {
                    'name': 'CrossAccountAccessRole',
                    'arn': 'arn:aws:iam::123456789012:role/CrossAccountAccessRole',
                    'trust_policy': 'arn:aws:iam::999999999999:root',
                    'max_session_duration': 7200,
                    'privilege_level': 'cross-account'
                }
            ]
            
            for role in iam_roles:
                session.run("""
                    MERGE (role:IAMRole {
                        name: $name,
                        arn: $arn,
                        trust_policy: $trust_policy,
                        max_session_duration: $max_session_duration,
                        privilege_level: $privilege_level,
                        discovered_via_cartography: true,
                        discovery_time: datetime(),
                        cartography_lastupdated: datetime()
                    })
                    WITH role
                    MATCH (account:AWSAccount {id: '123456789012'})
                    MERGE (account)-[:CONTAINS_ROLE]->(role)
                """, **role)
            
            print(f"   ✅ Discovered {len(iam_users)} IAM users and {len(iam_roles)} IAM roles")
    
    def discover_compute_network(self):
        """Discover EC2 instances, VPCs, and security groups"""
        with self.driver.session() as session:
            # VPC Discovery
            session.run("""
                MERGE (vpc:VPC {
                    id: 'vpc-0abc123def456789a',
                    cidr_block: '10.0.0.0/16',
                    is_default: false,
                    state: 'available',
                    discovered_via_cartography: true,
                    discovery_time: datetime(),
                    cartography_lastupdated: datetime()
                })
                WITH vpc
                MATCH (account:AWSAccount {id: '123456789012'})
                MERGE (account)-[:CONTAINS_VPC]->(vpc)
            """)
            
            # Security Groups
            security_groups = [
                {
                    'id': 'sg-0123456789abcdef0',
                    'name': 'web-servers',
                    'description': 'Security group for web servers',
                    'ingress_rules': '[{"port": 80, "protocol": "tcp", "source": "0.0.0.0/0"}, {"port": 443, "protocol": "tcp", "source": "0.0.0.0/0"}]'
                },
                {
                    'id': 'sg-0fedcba987654321f',
                    'name': 'database-servers',
                    'description': 'Security group for database servers',
                    'ingress_rules': '[{"port": 3306, "protocol": "tcp", "source": "sg-0123456789abcdef0"}]'
                },
                {
                    'id': 'sg-0987654321fedcba0',
                    'name': 'admin-access',
                    'description': 'Administrative access',
                    'ingress_rules': '[{"port": 22, "protocol": "tcp", "source": "0.0.0.0/0"}]'
                }
            ]
            
            for sg in security_groups:
                session.run("""
                    MERGE (sg:SecurityGroup {
                        id: $id,
                        name: $name,
                        description: $description,
                        ingress_rules: $ingress_rules,
                        discovered_via_cartography: true,
                        discovery_time: datetime(),
                        cartography_lastupdated: datetime()
                    })
                    WITH sg
                    MATCH (vpc:VPC {id: 'vpc-0abc123def456789a'})
                    MERGE (vpc)-[:CONTAINS_SECURITY_GROUP]->(sg)
                """, **sg)
            
            # EC2 Instances
            ec2_instances = [
                {
                    'id': 'i-0123456789abcdef0',
                    'instance_type': 't3.medium',
                    'state': 'running',
                    'public_ip': '54.123.45.67',
                    'private_ip': '10.0.1.100',
                    'iam_instance_profile': 'EC2AdminRole',
                    'security_groups': 'sg-0123456789abcdef0,sg-0987654321fedcba0'
                },
                {
                    'id': 'i-0fedcba987654321f',
                    'instance_type': 't3.large',
                    'state': 'running',
                    'public_ip': '',
                    'private_ip': '10.0.2.200',
                    'iam_instance_profile': '',
                    'security_groups': 'sg-0fedcba987654321f'
                }
            ]
            
            for instance in ec2_instances:
                session.run("""
                    MERGE (instance:EC2Instance {
                        id: $id,
                        instance_type: $instance_type,
                        state: $state,
                        public_ip: $public_ip,
                        private_ip: $private_ip,
                        iam_instance_profile: $iam_instance_profile,
                        security_groups: $security_groups,
                        discovered_via_cartography: true,
                        discovery_time: datetime(),
                        cartography_lastupdated: datetime()
                    })
                    WITH instance
                    MATCH (vpc:VPC {id: 'vpc-0abc123def456789a'})
                    MERGE (vpc)-[:CONTAINS_INSTANCE]->(instance)
                """, **instance)
            
            print(f"   ✅ Discovered 1 VPC, {len(security_groups)} security groups, and {len(ec2_instances)} EC2 instances")
    
    def discover_storage_databases(self):
        """Discover S3 buckets and RDS instances"""
        with self.driver.session() as session:
            # S3 Buckets
            s3_buckets = [
                {
                    'name': 'company-data-lake',
                    'arn': 'arn:aws:s3:::company-data-lake',
                    'public_read': False,
                    'public_write': False,
                    'encryption_enabled': True,
                    'versioning_enabled': True,
                    'contains_pii': True
                },
                {
                    'name': 'public-assets-bucket',
                    'arn': 'arn:aws:s3:::public-assets-bucket',
                    'public_read': True,
                    'public_write': False,
                    'encryption_enabled': False,
                    'versioning_enabled': False,
                    'contains_pii': False
                },
                {
                    'name': 'backup-storage-prod',
                    'arn': 'arn:aws:s3:::backup-storage-prod',
                    'public_read': False,
                    'public_write': False,
                    'encryption_enabled': True,
                    'versioning_enabled': True,
                    'contains_pii': True
                }
            ]
            
            for bucket in s3_buckets:
                session.run("""
                    MERGE (bucket:S3Bucket {
                        name: $name,
                        arn: $arn,
                        public_read: $public_read,
                        public_write: $public_write,
                        encryption_enabled: $encryption_enabled,
                        versioning_enabled: $versioning_enabled,
                        contains_pii: $contains_pii,
                        discovered_via_cartography: true,
                        discovery_time: datetime(),
                        cartography_lastupdated: datetime()
                    })
                    WITH bucket
                    MATCH (account:AWSAccount {id: '123456789012'})
                    MERGE (account)-[:CONTAINS_BUCKET]->(bucket)
                """, **bucket)
            
            print(f"   ✅ Discovered {len(s3_buckets)} S3 buckets")
    
    def discover_serverless_apis(self):
        """Discover Lambda functions and API Gateways"""
        with self.driver.session() as session:
            # Lambda Functions
            lambda_functions = [
                {
                    'name': 'user-authentication',
                    'arn': 'arn:aws:lambda:us-east-1:123456789012:function:user-authentication',
                    'runtime': 'nodejs18.x',
                    'role_arn': 'arn:aws:iam::123456789012:role/LambdaExecutionRole',
                    'environment_variables': '{"DB_HOST": "prod-db.cluster-xyz.us-east-1.rds.amazonaws.com", "API_KEY": "encrypted"}',
                    'has_vpc_access': True
                },
                {
                    'name': 'data-processor',
                    'arn': 'arn:aws:lambda:us-east-1:123456789012:function:data-processor',
                    'runtime': 'python3.9',
                    'role_arn': 'arn:aws:iam::123456789012:role/LambdaExecutionRole',
                    'environment_variables': '{"S3_BUCKET": "company-data-lake", "KMS_KEY": "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"}',
                    'has_vpc_access': False
                }
            ]
            
            for func in lambda_functions:
                session.run("""
                    MERGE (lambda:LambdaFunction {
                        name: $name,
                        arn: $arn,
                        runtime: $runtime,
                        role_arn: $role_arn,
                        environment_variables: $environment_variables,
                        has_vpc_access: $has_vpc_access,
                        discovered_via_cartography: true,
                        discovery_time: datetime(),
                        cartography_lastupdated: datetime()
                    })
                    WITH lambda
                    MATCH (account:AWSAccount {id: '123456789012'})
                    MERGE (account)-[:CONTAINS_LAMBDA]->(lambda)
                """, **func)
            
            # API Gateways
            session.run("""
                MERGE (api:APIGateway {
                    id: 'abc123defg',
                    name: 'customer-api-gateway',
                    stage: 'prod',
                    endpoint_url: 'https://abc123defg.execute-api.us-east-1.amazonaws.com/prod',
                    authentication: 'none',
                    discovered_via_cartography: true,
                    discovery_time: datetime(),
                    cartography_lastupdated: datetime()
                })
                WITH api
                MATCH (account:AWSAccount {id: '123456789012'})
                MERGE (account)-[:CONTAINS_API]->(api)
            """)
            
            print(f"   ✅ Discovered {len(lambda_functions)} Lambda functions and 1 API Gateway")
    
    def discover_relationships(self):
        """Discover relationships between resources"""
        with self.driver.session() as session:
            # IAM User -> Role assumptions
            session.run("""
                MATCH (user:IAMUser {username: 'sarah.chen'})
                MATCH (role:IAMRole {name: 'EC2AdminRole'})
                MERGE (user)-[:CAN_ASSUME_ROLE {
                    discovered_via_cartography: true,
                    discovery_time: datetime()
                }]->(role)
            """)
            
            # EC2 Instance -> IAM Role
            session.run("""
                MATCH (instance:EC2Instance {id: 'i-0123456789abcdef0'})
                MATCH (role:IAMRole {name: 'EC2AdminRole'})
                MERGE (instance)-[:HAS_INSTANCE_PROFILE {
                    discovered_via_cartography: true,
                    discovery_time: datetime()
                }]->(role)
            """)
            
            # Lambda -> IAM Role
            session.run("""
                MATCH (lambda:LambdaFunction)
                MATCH (role:IAMRole {name: 'LambdaExecutionRole'})
                MERGE (lambda)-[:EXECUTES_WITH_ROLE {
                    discovered_via_cartography: true,
                    discovery_time: datetime()
                }]->(role)
            """)
            
            # API Gateway -> Lambda
            session.run("""
                MATCH (api:APIGateway {name: 'customer-api-gateway'})
                MATCH (lambda:LambdaFunction {name: 'user-authentication'})
                MERGE (api)-[:INVOKES {
                    discovered_via_cartography: true,
                    discovery_time: datetime()
                }]->(lambda)
            """)
            
            # Lambda -> S3 access
            session.run("""
                MATCH (lambda:LambdaFunction {name: 'data-processor'})
                MATCH (bucket:S3Bucket {name: 'company-data-lake'})
                MERGE (lambda)-[:CAN_ACCESS {
                    permissions: 'read,write',
                    discovered_via_cartography: true,
                    discovery_time: datetime()
                }]->(bucket)
            """)
            
            print("   ✅ Discovered cross-service relationships and permissions")
    
    def analyze_security_posture(self):
        """Analyze discovered infrastructure for security issues"""
        with self.driver.session() as session:
            # Mark high-risk configurations
            session.run("""
                MATCH (sg:SecurityGroup)
                WHERE sg.ingress_rules CONTAINS '"source": "0.0.0.0/0"'
                SET sg.security_risk = 'HIGH',
                    sg.risk_reason = 'Allows inbound traffic from internet',
                    sg.risk_analysis_time = datetime()
            """)
            
            session.run("""
                MATCH (bucket:S3Bucket)
                WHERE bucket.public_read = true OR bucket.encryption_enabled = false
                SET bucket.security_risk = 'MEDIUM',
                    bucket.risk_reason = 'Public access or unencrypted storage',
                    bucket.risk_analysis_time = datetime()
            """)
            
            session.run("""
                MATCH (user:IAMUser)
                WHERE user.mfa_enabled = false AND user.access_level IN ['admin', 'contractor']
                SET user.security_risk = 'HIGH',
                    user.risk_reason = 'Privileged user without MFA',
                    user.risk_analysis_time = datetime()
            """)
            
            print("   ✅ Completed security posture analysis")
    
    def print_discovery_summary(self):
        """Print summary of discovered assets"""
        with self.driver.session() as session:
            # Count discovered assets
            result = session.run("""
                MATCH (n)
                WHERE n.discovered_via_cartography = true
                RETURN labels(n)[0] as AssetType, count(n) as Count
                ORDER BY Count DESC
            """)
            
            print("📊 Discovery Summary:")
            print("-" * 30)
            total_assets = 0
            for record in result:
                asset_type = record["AssetType"]
                count = record["Count"]
                total_assets += count
                print(f"   {asset_type}: {count}")
            
            print("-" * 30)
            print(f"   Total Assets: {total_assets}")
            
            # Count relationships
            rel_result = session.run("""
                MATCH ()-[r]->()
                WHERE r.discovered_via_cartography = true
                RETURN count(r) as RelationshipCount
            """)
            
            rel_count = rel_result.single()["RelationshipCount"]
            print(f"   Relationships: {rel_count}")
            
            # Security risks
            risk_result = session.run("""
                MATCH (n)
                WHERE n.security_risk IS NOT NULL
                RETURN n.security_risk as RiskLevel, count(n) as Count
                ORDER BY Count DESC
            """)
            
            print("\n🔍 Security Analysis:")
            print("-" * 30)
            for record in risk_result:
                risk_level = record["RiskLevel"]
                count = record["Count"]
                print(f"   {risk_level} Risk: {count} assets")

def main():
    """Main execution function"""
    simulator = AssetDiscoverySimulator()
    
    try:
        simulator.run_discovery_simulation()
        print("\n🎯 Asset discovery complete!")
        print("💡 Use Neo4j Browser to explore discovered infrastructure")
        print("🔍 Try queries like:")
        print("   MATCH (n) WHERE n.discovered_via_cartography = true RETURN n LIMIT 25")
        print("   MATCH (n) WHERE exists(n.security_risk) RETURN n")
        
    except Exception as e:
        print(f"❌ Discovery simulation failed: {e}")
        sys.exit(1)
    finally:
        simulator.close()

if __name__ == "__main__":
    main()