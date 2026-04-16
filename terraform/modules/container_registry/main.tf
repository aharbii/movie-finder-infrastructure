# =============================================================================
# module: container_registry
# Azure Container Registry for movie-finder images.
# =============================================================================

resource "azurerm_container_registry" "main" {
  name                = replace("${var.prefix}${var.environment}", "-", "")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  tags                = var.tags
}
