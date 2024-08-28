#modules/rds/outputs.tf
output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.this.id
}

output "rds_secret_name" {
  description = "The name of the RDS secret"
  value       = aws_secretsmanager_secret.rds_secret.name  # Corrected reference
}

output "rds_secret_version_id" {
  description = "The version ID of the RDS secret"
  value       = aws_secretsmanager_secret_version.rds_secret_value.version_id  # Corrected reference
}

output "db_name" {
  description = "The database name"
  value       = var.db_name
}

output "username" {
  description = "The database username"
  value       = var.username
}

output "password" {
  description = "The database password"
  value       = var.password
}