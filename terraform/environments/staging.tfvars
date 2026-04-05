# =============================================================================
# movie-finder — Staging environment variables
#
# DO NOT commit secrets. Supply sensitive variables via:
#   - CI/CD pipeline secrets (recommended)
#   - terraform.tfvars (gitignored)
#   - Environment variables: TF_VAR_<name>=<value>
# =============================================================================

environment = "staging"
location    = "eastus"

tags = {
  project     = "movie-finder"
  environment = "staging"
}

# Container Registry
acr_sku           = "Standard"
acr_admin_enabled = true

# Database
db_sku_name  = "B_Standard_B1ms"
db_storage_mb = 32768
db_version   = "16"

# Container Apps — staging runs minimal replicas
backend_min_replicas  = 1
backend_max_replicas  = 2
frontend_min_replicas = 1
frontend_max_replicas = 2

# Key Vault
key_vault_sku = "standard"
