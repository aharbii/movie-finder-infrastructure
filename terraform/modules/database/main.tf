# =============================================================================
# module: database
# Azure Database for PostgreSQL Flexible Server.
# =============================================================================

resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.prefix}-db-${var.environment}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgresql_version
  delegated_subnet_id    = var.delegated_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  zone                   = "1"
  tags                   = var.tags

  high_availability {
    mode = var.environment == "production" ? "ZoneRedundant" : "Disabled"
  }

  backup_retention_days        = var.environment == "production" ? 35 : 7
  geo_redundant_backup_enabled = var.environment == "production"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [zone, high_availability[0].standby_availability_zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "movie_finder"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "utf8"
  collation = "en_US.utf8"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "PG_TRGM,BTREE_GIN"
}
