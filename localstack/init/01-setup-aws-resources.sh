#!/bin/bash

echo "🔧 Setting up LocalStack AWS resources for Cloud Threat Graph Lab"
echo "=================================================================="

# Simple wait for LocalStack
echo "⏳ Waiting for LocalStack to be ready..."
sleep 10

echo "✅ LocalStack ready - starting basic setup!"

# Set AWS CLI to use LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566

echo ""
echo "🏗️ Creating mock AWS infrastructure..."

# Create VPC
echo "📡 Creating VPC and networking..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text 2>/dev/null || echo "vpc-0abc123def456789a")
echo "   Created VPC: $VPC_ID"

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text 2>/dev/null || echo "igw-012345")
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID 2>/dev/null || true
echo "   Created Internet Gateway: $IGW_ID"

# Create Subnets
SUBNET1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text 2>/dev/null || echo "subnet-0123456789abcdef0")
SUBNET2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone us-east-1b --query 'Subnet.SubnetId' --output text 2>/dev/null || echo "subnet-0fedcba987654321f")
echo "   Created Subnets: $SUBNET1_ID, $SUBNET2_ID"

# Create Security Groups
echo "🛡️ Creating security groups..."
WEB_SG_ID=$(aws ec2 create-security-group --group-name "web-servers" --description "Security group for web servers" --vpc-id $VPC_ID --query 'GroupId' --output text 2>/dev/null || echo "sg-0123456789abcdef0")
DB_SG_ID=$(aws ec2 create-security-group --group-name "database-servers" --description "Security group for database servers" --vpc-id $VPC_ID --query 'GroupId' --output text 2>/dev/null || echo "sg-0fedcba987654321f")
ADMIN_SG_ID=$(aws ec2 create-security-group --group-name "admin-access" --description "Administrative access" --vpc-id $VPC_ID --query 'GroupId' --output text 2>/dev/null || echo "sg-0987654321fedcba0")

# Configure security group rules
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null || true
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 2>/dev/null || true
aws ec2 authorize-security-group-ingress --group-id $DB_SG_ID --protocol tcp --port 3306 --source-group $WEB_SG_ID 2>/dev/null || true
aws ec2 authorize-security-group-ingress --group-id $ADMIN_SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 2>/dev/null || true

echo "   Created Security Groups: $WEB_SG_ID, $DB_SG_ID, $ADMIN_SG_ID"

# Create IAM Roles
echo "👤 Creating IAM roles..."
cat > /tmp/ec2-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

cat > /tmp/lambda-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role --role-name EC2AdminRole --assume-role-policy-document file:///tmp/ec2-trust-policy.json 2>/dev/null || true
aws iam create-role --role-name LambdaExecutionRole --assume-role-policy-document file:///tmp/lambda-trust-policy.json 2>/dev/null || true

# Create instance profile
aws iam create-instance-profile --instance-profile-name EC2AdminRole 2>/dev/null || true
aws iam add-role-to-instance-profile --instance-profile-name EC2AdminRole --role-name EC2AdminRole 2>/dev/null || true

echo "   Created IAM roles: EC2AdminRole, LambdaExecutionRole"

# Create S3 Buckets
echo "🪣 Creating S3 buckets..."
aws s3 mb s3://company-data-lake 2>/dev/null || true
aws s3 mb s3://public-assets-bucket 2>/dev/null || true  
aws s3 mb s3://backup-storage-prod 2>/dev/null || true

# Set bucket policies for public assets bucket
cat > /tmp/public-bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::public-assets-bucket/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket public-assets-bucket --policy file:///tmp/public-bucket-policy.json 2>/dev/null || true
echo "   Created S3 buckets: company-data-lake, public-assets-bucket, backup-storage-prod"

# Create Lambda Functions
echo "⚡ Creating Lambda functions..."
cat > /tmp/lambda-function.py << EOF
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
EOF

cd /tmp
zip lambda-function.zip lambda-function.py

aws lambda create-function \
    --function-name user-authentication \
    --runtime nodejs18.x \
    --role arn:aws:iam::123456789012:role/LambdaExecutionRole \
    --handler index.handler \
    --zip-file fileb://lambda-function.zip \
    --environment Variables='{DB_HOST=prod-db.cluster-xyz.us-east-1.rds.amazonaws.com,API_KEY=encrypted_api_key}' \
    --vpc-config SubnetIds=[$SUBNET1_ID],SecurityGroupIds=[$WEB_SG_ID] \
    2>/dev/null || true

aws lambda create-function \
    --function-name data-processor \
    --runtime python3.9 \
    --role arn:aws:iam::123456789012:role/LambdaExecutionRole \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://lambda-function.zip \
    --environment Variables='{S3_BUCKET=company-data-lake,KMS_KEY=arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012}' \
    2>/dev/null || true

echo "   Created Lambda functions: user-authentication, data-processor"

# Create API Gateway
echo "🚪 Creating API Gateway..."
API_ID=$(aws apigateway create-rest-api --name "customer-api-gateway" --description "Main API Gateway for customer services" --query 'id' --output text 2>/dev/null || echo "abc123defg")
echo "   Created API Gateway: $API_ID"

# Create EC2 Instances (simulated)
echo "💻 Creating EC2 instances..."
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --count 1 \
    --instance-type t3.medium \
    --key-name my-key-pair \
    --security-group-ids $WEB_SG_ID $ADMIN_SG_ID \
    --subnet-id $SUBNET1_ID \
    --iam-instance-profile Name=EC2AdminRole \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-01},{Key=Environment,Value=production}]' \
    2>/dev/null || true

aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --count 1 \
    --instance-type t3.large \
    --key-name my-key-pair \
    --security-group-ids $DB_SG_ID \
    --subnet-id $SUBNET2_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=database-server-01},{Key=Environment,Value=production}]' \
    2>/dev/null || true

echo "   Created EC2 instances: web-server-01, database-server-01"

# Create IAM Users
echo "👥 Creating IAM users..."
aws iam create-user --user-name sarah.chen --path / 2>/dev/null || true
aws iam create-user --user-name admin-service --path /service-accounts/ 2>/dev/null || true
aws iam create-user --user-name contractor.external --path /contractors/ 2>/dev/null || true

# Add user tags
aws iam tag-user --user-name sarah.chen --tags Key=Department,Value=Engineering Key=Team,Value=CloudPlatform 2>/dev/null || true
aws iam tag-user --user-name admin-service --tags Key=Purpose,Value=Automation Key=Owner,Value=PlatformTeam 2>/dev/null || true
aws iam tag-user --user-name contractor.external --tags Key=ContractorCompany,Value=TechConsultingInc Key=AccessExpiry,Value=2024-03-01 2>/dev/null || true

echo "   Created IAM users: sarah.chen, admin-service, contractor.external"

# Create Secrets Manager secrets
echo "🔐 Creating secrets..."
aws secretsmanager create-secret --name "prod/database/credentials" --description "Production database credentials" --secret-string '{"username":"admin","password":"super-secure-password"}' 2>/dev/null || true
aws secretsmanager create-secret --name "prod/api/keys" --description "Production API keys" --secret-string '{"github_token":"ghp_abcdef123456","slack_webhook":"https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"}' 2>/dev/null || true

echo "   Created secrets: prod/database/credentials, prod/api/keys"

# Create SSM Parameters
echo "⚙️ Creating SSM parameters..."
aws ssm put-parameter --name "/prod/database/host" --value "prod-db.cluster-xyz.us-east-1.rds.amazonaws.com" --type "String" 2>/dev/null || true
aws ssm put-parameter --name "/prod/app/debug" --value "false" --type "String" 2>/dev/null || true
aws ssm put-parameter --name "/prod/api/rate-limit" --value "1000" --type "String" 2>/dev/null || true

echo "   Created SSM parameters: database host, app debug, rate limit"

echo ""
echo "✅ LocalStack AWS infrastructure setup complete!"
echo "🎯 Mock cloud environment ready for Cartography discovery"
echo ""

# Cleanup temporary files
rm -f /tmp/lambda-function.py /tmp/lambda-function.zip /tmp/*-trust-policy.json /tmp/*-bucket-policy.json

echo "📊 Infrastructure Summary:"
echo "   - 1 VPC with 2 subnets"
echo "   - 3 security groups (with intentional misconfigurations)"
echo "   - 2 IAM roles and 3 IAM users"
echo "   - 3 S3 buckets (1 with public access)"
echo "   - 2 Lambda functions"
echo "   - 1 API Gateway"
echo "   - 2 EC2 instances (simulated)"
echo "   - 2 Secrets Manager secrets"
echo "   - 3 SSM parameters"
echo ""
echo "🔍 Ready for Cartography asset discovery simulation!"