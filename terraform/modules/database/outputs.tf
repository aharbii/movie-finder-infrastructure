output "id"   { value = azurerm_postgresql_flexible_server.main.id }
output "host" { value = azurerm_postgresql_flexible_server.main.fqdn }
output "connection_string" {
  sensitive = true
  value     = "postgresql://${var.admin_username}:${var.admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.app.name}"
}
