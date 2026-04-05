# =============================================================================
# movie-finder — Production environment variables
#
# DO NOT commit secrets. Supply sensitive variables via CI/CD pipeline secrets.
# =============================================================================

environment = "production"
location    = "eastus"

tags = {
  project     = "movie-finder"
  environment = "production"
}

# Container Registry
acr_sku           = "Standard"
acr_admin_enabled = true

# Database — production uses a larger SKU with ZoneRedundant HA
db_sku_name  = "GP_Standard_D2s_v3"
db_storage_mb = 65536
db_version   = "16"

# Container Apps — production runs higher replica counts
backend_min_replicas  = 2
backend_max_replicas  = 5
frontend_min_replicas = 2
frontend_max_replicas = 5

# Key Vault
key_vault_sku = "standard"
