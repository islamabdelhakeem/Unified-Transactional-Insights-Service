resource "aws_sqs_queue" "transaction_dlq" {
  name                      = "${var.project_name}-${var.environment}-transaction-dlq"
  message_retention_seconds = var.sqs_message_retention_seconds

  kms_master_key_id                 = aws_kms_key.sqs.id
  kms_data_key_reuse_period_seconds = 300

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-transaction-dlq"
      Environment = var.environment
      Purpose     = "Dead Letter Queue for failed transaction messages"
    }
  )
}

resource "aws_sqs_queue" "transaction_queue" {
  name                       = "${var.project_name}-${var.environment}-transaction-queue"
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = 300
  receive_wait_time_seconds  = 20

  kms_master_key_id                 = aws_kms_key.sqs.id
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.transaction_dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-transaction-queue"
      Environment = var.environment
      Purpose     = "Main queue for transaction processing"
    }
  )
}

resource "aws_kms_key" "sqs" {
  description             = "KMS key for SQS encryption - ${var.environment}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-sqs-kms"
      Environment = var.environment
    }
  )
}

resource "aws_kms_alias" "sqs" {
  name          = "alias/${var.project_name}-${var.environment}-sqs"
  target_key_id = aws_kms_key.sqs.key_id
}
