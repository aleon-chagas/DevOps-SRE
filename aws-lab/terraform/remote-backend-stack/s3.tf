# Cria o bucket S3 para armazenar o arquivo terraform.tfstate.
resource "aws_s3_bucket" "this" {
  # Usaremos o mesmo nome fixo que está no 'main.tf' do outro stack.
  bucket        = var.bucket_name
  force_destroy = true # Permite destruir mesmo com conteúdo
}

# Habilita o versionamento para segurança e rollback do estado.
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Habilita criptografia padrão do bucket usando AWS KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Bloqueia acesso público ao bucket por segurança
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}