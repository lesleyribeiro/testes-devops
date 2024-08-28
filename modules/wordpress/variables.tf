variable "rds_secret_name" {
  type        = string
  description = "Name of the RDS secret in AWS Secrets Manager"
}

variable "namespace" {
  description = "Namespace for the WordPress deployment"
  type        = string
}

variable "db_name" {
  description = "The database name"
  type        = string
}

variable "username" {
  description = "The database username"
  type        = string
}

variable "password" {
  description = "The database password"
  type        = string
}

variable "db_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  type        = string
}
