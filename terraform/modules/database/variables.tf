variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "prefix"              { type = string }
variable "sku_name"            { type = string }
variable "storage_mb"          { type = number }
variable "postgresql_version"  { type = string }
variable "admin_username"      { type = string; sensitive = true }
variable "admin_password"      { type = string; sensitive = true }
variable "delegated_subnet_id" { type = string }
variable "private_dns_zone_id" { type = string }
variable "tags"                { type = map(string) }
