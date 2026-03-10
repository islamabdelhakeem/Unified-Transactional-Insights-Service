module "unified_transactions" {
  source = "./unified_transactions"

  environment        = var.environment
  project_name       = var.project_name
  vpc_id             = var.vpc_id
  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids

  db_instance_class          = var.db_instance_class
  db_allocated_storage       = var.db_allocated_storage
  db_name                    = var.db_name
  db_backup_retention_period = var.db_backup_retention_period
  db_multi_az                = var.db_multi_az

  ecs_task_cpu      = var.ecs_task_cpu
  ecs_task_memory   = var.ecs_task_memory
  ecs_desired_count = var.ecs_desired_count
  container_image   = var.container_image
  container_port    = var.container_port

  sqs_message_retention_seconds = var.sqs_message_retention_seconds
  sqs_max_receive_count         = var.sqs_max_receive_count

  tags = var.tags
}