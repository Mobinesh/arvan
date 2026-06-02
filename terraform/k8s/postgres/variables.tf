variable "postgres_password" {
  description = "PostgreSQL superuser password"
  type        = string
  sensitive   = true
}

variable "postgres_app_password" {
  description = "PostgreSQL application user password"
  type        = string
  sensitive   = true
}
