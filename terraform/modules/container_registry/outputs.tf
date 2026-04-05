output "id"             { value = azurerm_container_registry.main.id }
output "login_server"  { value = azurerm_container_registry.main.login_server }
output "admin_username" {
  value     = var.admin_enabled ? azurerm_container_registry.main.admin_username : null
  sensitive = true
}
output "admin_password" {
  value     = var.admin_enabled ? azurerm_container_registry.main.admin_password : null
  sensitive = true
}
