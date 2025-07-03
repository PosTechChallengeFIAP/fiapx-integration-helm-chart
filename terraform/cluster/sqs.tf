resource "aws_sqs_queue" "processing-request-queue" {
  name                      = "processing-request-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Environment = "dev"
    Name        = "processing-request-queue"
  }
}

output "sqs_queue_url" {
  value = base64encode(aws_sqs_queue.processing-request-queue.url)
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.processing-request-queue.arn
}
