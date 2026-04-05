# =============================================================================
# movie-finder — Terraform root module
#
# Primary cloud: Azure
# Optional clouds: AWS, GCP (enable via variables)
#
# Resource naming convention: movie-finder-<component>-<environment>
# =============================================================================

locals {
  prefix = "movie-finder"
  env    = var.environment

  default_tags = merge(
    {
      project     = "movie-finder"
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Resource Groups
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-${local.env}"
  location = var.location
  tags     = local.default_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Networking
# ─────────────────────────────────────────────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = local.env
  prefix              = local.prefix
  tags                = local.default_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Azure Container Registry
# ─────────────────────────────────────────────────────────────────────────────

module "container_registry" {
  source = "./modules/container_registry"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = local.env
  prefix              = local.prefix
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  tags                = local.default_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Azure Key Vault
# ─────────────────────────────────────────────────────────────────────────────

module "key_vault" {
  source = "./modules/key_vault"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = local.env
  prefix              = local.prefix
  sku_name            = var.key_vault_sku
  tags                = local.default_tags

  # Application secrets — injected at apply time, never stored in plaintext
  secrets = {
    app-secret-key     = var.app_secret_key
    openai-api-key     = var.openai_api_key
    anthropic-api-key  = var.anthropic_api_key
    qdrant-url         = var.qdrant_url
    qdrant-api-key-ro  = var.qdrant_api_key_ro
    langsmith-api-key  = var.langsmith_api_key
    db-admin-username  = var.db_admin_username
    db-admin-password  = var.db_admin_password
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# PostgreSQL Flexible Server
# ─────────────────────────────────────────────────────────────────────────────

module "database" {
  source = "./modules/database"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = local.env
  prefix              = local.prefix
  sku_name            = var.db_sku_name
  storage_mb          = var.db_storage_mb
  postgresql_version  = var.db_version
  admin_username      = var.db_admin_username
  admin_password      = var.db_admin_password
  delegated_subnet_id = module.networking.db_subnet_id
  private_dns_zone_id = module.networking.db_private_dns_zone_id
  tags                = local.default_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Azure Container Apps
# ─────────────────────────────────────────────────────────────────────────────

module "container_apps" {
  source = "./modules/container_apps"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  environment                = local.env
  prefix                     = local.prefix
  infrastructure_subnet_id   = module.networking.apps_subnet_id
  acr_login_server           = module.container_registry.login_server
  acr_admin_username         = module.container_registry.admin_username
  acr_admin_password         = module.container_registry.admin_password
  key_vault_id               = module.key_vault.id
  backend_image_tag          = var.backend_image_tag
  frontend_image_tag         = var.frontend_image_tag
  backend_min_replicas       = var.backend_min_replicas
  backend_max_replicas       = var.backend_max_replicas
  frontend_min_replicas      = var.frontend_min_replicas
  frontend_max_replicas      = var.frontend_max_replicas
  database_url               = module.database.connection_string
  tags                       = local.default_tags
}
