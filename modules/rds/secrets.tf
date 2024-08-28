#modules/rds/secret.tf
resource "random_string" "rds_secret_suffix" {
  length  = 4
  special = false
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds-secret-${random_string.rds_secret_suffix.result}"
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.username
    password = var.password
  })
}
