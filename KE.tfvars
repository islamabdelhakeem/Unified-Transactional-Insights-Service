profile = "default"
region  = "us-east-1"

environment  = "production"
project_name = "unified-transactions"

vpc_id = "vpc-0123456789abcdef0"

public_subnet_ids = [
  "subnet-0123456789abcdef0",
  "subnet-0123456789abcdef1"
]

private_subnet_ids = [
  "subnet-0123456789abcdef2",
  "subnet-0123456789abcdef3"
]

db_instance_class          = "db.t3.micro"
db_allocated_storage       = 20
db_name                    = "unified_transactions_db"
db_backup_retention_period = 7
db_multi_az                = true

ecs_task_cpu      = "512"
ecs_task_memory   = "1024"
ecs_desired_count = 2
container_image   = "nginx:latest"
container_port    = 80

sqs_message_retention_seconds = 345600
sqs_max_receive_count         = 3

tags = {
  Environment = "production"
  Country     = "Kenya"
  ManagedBy   = "Terraform"
  Project     = "UnifiedTransactions"
}