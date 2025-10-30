resource "aws_sqs_queue" "this" {
  count = length(var.queue)

  name                      = "${var.queue[count.index].name}-${terraform.workspace}"
  delay_seconds             = var.queue[count.index].delay_seconds
  max_message_size          = var.queue[count.index].max_message_size
  message_retention_seconds = var.queue[count.index].message_retention_seconds
  receive_wait_time_seconds = var.queue[count.index].receive_wait_time_seconds
}