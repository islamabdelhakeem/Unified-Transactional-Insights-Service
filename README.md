# Unified Transactions & Insights Service - Terraform Infrastructure

This repository contains Infrastructure as Code (IaC) using Terraform to provision the foundational infrastructure for Kasha's **Unified Transactions & Insights Service**.

## Overview

The infrastructure provisions  architecture on AWS that supports:
- **Asynchronous transaction processing** via SQS queues
- **Containerized microservices** using ECS Fargate
- **Persistent data storage** with encrypted RDS MySQL
- **Secure credential management** via AWS Secrets Manager
- **High availability** with Application Load Balancer
- **Multi-country deployment** support without impacting HIV PDS performance

## Architecture

### Infrastructure Components

1. **SQS Queue with DLQ**
   - Main transaction queue for processing messages from HIV PDS
   - Dead Letter Queue (DLQ) for failed message handling
   - Encrypted at rest using AWS KMS
   - Configurable message retention and max receive count

2. **ECS Fargate Service**
   - Fully managed container orchestration
   - Auto-scaling capabilities
   - Deployed in private subnets for security

3. **Application Load Balancer (ALB)**
   - Public-facing endpoint for API access
   - Health checks with automatic target deregistration
   - Deployed in public subnets across multiple AZs

4. **RDS MySQL Database**
   - Encrypted at rest using AWS KMS
   - Automated backups (7-day retention default)
   - Multi-AZ deployment support for high availability
   - Deployed in private subnets with restricted security group access

5. **AWS Secrets Manager**
   - Auto-generated database credentials
   - Secure credential rotation support
   - Accessible by ECS tasks via IAM policies

6. **Security Groups**
   - ALB: Allows HTTP/HTTPS from internet
   - ECS: Allows traffic only from ALB
   - RDS: Allows MySQL traffic only from ECS

7. **IAM Roles**
   - **Task Execution Role**: Allows ECS to pull images and access Secrets Manager
   - **Task Role**: Allows containers to access SQS and Secrets Manager

## Project Structure

```
terraform-unified-transactions-service/
├── main.tf                          # Root module - calls unified_transactions module
├── variables.tf                     # Root-level variables
├── provider.tf                      # AWS provider configuration
├── versions.tf                      # Terraform version constraints
├── KE.tfvars                       # Kenya environment configuration
├── README.md                        # This file
└── unified_transactions/            # Reusable module
    ├── variables.tf                 # Module input variables
    ├── sqs.tf                       # SQS queue and DLQ
    ├── secrets.tf                   # Secrets Manager for DB credentials
    ├── rds.tf                       # RDS instance with encryption
    ├── security_groups.tf           # Security groups for ALB, ECS, RDS
    ├── iam.tf                       # IAM roles and policies
    ├── alb.tf                       # Application Load Balancer
    ├── ecs.tf                       # ECS cluster, task, and service
    └── outputs.tf                   # Module outputs
```



##  Usage


### Configuration

1. **Set AWS Credentials**

   There are two ways to configure AWS credentials:

   **Option 1: Environment Variables**
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_REGION="us-east-1"
   terraform plan
   ```

   **Option 2: Shared Configuration and Credentials Files (Recommended)**
   
   In Linux OS, credentials are stored in `$HOME/.aws/credentials`:
   ```ini
   [default]
   aws_access_key_id = your-access-key
   aws_secret_access_key = your-secret-key
   aws_session_token = your-session-token  # Optional
   ```
   
   By default, Terraform uses the `[default]` profile if not specified. To use a different profile (e.g., "kasha"), pass the `profile` argument to the provider in `provider.tf` or via tfvars:
   ```bash
   terraform plan -var-file="KE.tfvars" -var="profile=kasha"
   ```

2. **Update tfvars File**

   Edit `KE.tfvars` (or create a new `.tfvars` for your country):
   
   ```hcl
   vpc_id = "vpc-xxxxxxxxxxxxxxxxx"  # Your actual VPC ID
   
   public_subnet_ids = [
     "subnet-xxxxxxxxxxxxxxxxx",      # Replace with real subnet IDs
     "subnet-yyyyyyyyyyyyyyyyy"
   ]
   
   private_subnet_ids = [
     "subnet-zzzzzzzzzzzzzzzzz",      # Replace with real subnet IDs
     "subnet-aaaaaaaaaaaaaaaaa"
   ]
   ```

### Deployment

1. **Initialize Terraform**

   ```bash
   terraform init
   ```

2. **Validate Configuration**

   ```bash
   terraform validate
   ```

3. **Format Code**

   ```bash
   terraform fmt
   ```

4. **Plan Infrastructure**

   ```bash
   terraform plan -var-file="KE.tfvars"
   ```

5. **Review Plan Output**
   
   Since this is a plan-only exercise, review the planned resources without applying.

### Multi-Country Deployment

For deploying to multiple countries:

```bash
# Kenya
terraform workspace new kenya
terraform plan -var-file="KE.tfvars"

# Rwanda
terraform workspace new rwanda
terraform plan -var-file="RW.tfvars"

```

## Outputs

After running, the following outputs will be available:

| Output | Description |
|--------|-------------|
| `alb_dns_name` | DNS name of the Application Load Balancer |
| `sqs_queue_url` | URL of the main transaction queue |
| `sqs_dlq_url` | URL of the Dead Letter Queue |
| `rds_endpoint` | RDS database endpoint |
| `ecs_cluster_name` | Name of the ECS cluster |
| `db_credentials_secret_arn` | ARN of DB credentials in Secrets Manager |

## Security Features

- **No hardcoded secrets** - All credentials managed via Secrets Manager
- **Encryption at rest** - RDS and SQS encrypted with KMS
- **Encryption in transit** - HTTPS supported on ALB
- **Least privilege IAM** - Minimal permissions for each role
- **Network isolation** - Private subnets for compute and data layers
- **Security groups** - Restricted inbound/outbound
- **Automated backups** - RDS daily backups with 7-day retention 
- **KMS key rotation** - Automatic key rotation enabled

##  Customization

### Scaling Configuration

Modify in your `.tfvars` file:

```hcl
# ECS Scaling
ecs_desired_count = 2        # Number of containers
ecs_task_cpu      = "512"    # CPU units (256, 512, 1024, 2048, 4096)
ecs_task_memory   = "1024"   # Memory in MB

# RDS Scaling
db_instance_class = "db.t3.micro"  # Instance type
db_allocated_storage = 20          # Storage in GB
db_multi_az = true                 # Enable Multi-AZ
```

### Cost Optimization

For development/testing environments:

```hcl
environment = "dev"
db_instance_class = "db.t3.micro"
db_multi_az = false
ecs_desired_count = 1
```
