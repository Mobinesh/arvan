output "postgres_host" {
  value = "postgresql.postgres.svc.cluster.local"
}

output "postgres_port" {
  value = 5432
}

output "postgres_database" {
  value = "appdb"
}

output "postgres_user" {
  value = "appuser"
}
