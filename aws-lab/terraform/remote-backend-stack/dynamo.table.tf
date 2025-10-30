# Cria a tabela DynamoDB para o mecanismo de bloqueio (lock) do estado.
resource "aws_dynamodb_table" "this" {
  # Usaremos o mesmo nome fixo que está no 'main.tf' do outro stack.
  name = var.dynamodb_table_name
  # O 'PAY_PER_REQUEST' (sob demanda) é uma boa prática para evitar custo fixo.
  billing_mode = "PAY_PER_REQUEST"
  # A chave primária (hash_key) DEVE ser 'LockID' para funcionar como backend.
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Point-in-time recovery para backup
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = var.dynamodb_table_name
    Description = "Terraform State Lock Table"
    Purpose     = "State Locking"
  }
}