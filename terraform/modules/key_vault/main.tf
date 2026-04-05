# =============================================================================
# module: key_vault
# Azure Key Vault for runtime secrets injected via managed identity.
# =============================================================================

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = "${var.prefix}-kv-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku_name                   = var.sku_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = var.environment == "production"
  soft_delete_retention_days = 7
  tags                       = var.tags

  # Allow the Terraform service principal to manage secrets during apply.
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover",
    ]
  }
}

# Secrets with empty string values are skipped (optional secrets not configured).
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = { for k, v in var.secrets : k => v if v != "" }
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.main.id

  lifecycle {
    # Rotate secrets via Azure Key Vault UI or az keyvault secret set,
    # not through Terraform — prevents accidental downgrades on re-apply.
    ignore_changes = [value]
  }
}
