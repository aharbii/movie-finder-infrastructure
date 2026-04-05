# =============================================================================
# movie-finder — Terraform outputs
# =============================================================================

output "backend_url" {
  description = "Public URL of the backend Container App."
  value       = module.container_apps.backend_url
}

output "frontend_url" {
  description = "Public URL of the frontend Container App."
  value       = module.container_apps.frontend_url
}

output "acr_login_server" {
  description = "Azure Container Registry login server hostname."
  value       = module.container_registry.login_server
}

output "key_vault_uri" {
  description = "Azure Key Vault URI."
  value       = module.key_vault.uri
}

output "database_host" {
  description = "PostgreSQL Flexible Server hostname."
  value       = module.database.host
}
