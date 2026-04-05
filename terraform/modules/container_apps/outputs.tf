output "backend_url"  { value = "https://${azurerm_container_app.backend.latest_revision_fqdn}" }
output "frontend_url" { value = "https://${azurerm_container_app.frontend.latest_revision_fqdn}" }
