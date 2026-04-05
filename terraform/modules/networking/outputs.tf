output "apps_subnet_id"           { value = azurerm_subnet.apps.id }
output "db_subnet_id"             { value = azurerm_subnet.db.id }
output "db_private_dns_zone_id"   { value = azurerm_private_dns_zone.db.id }
