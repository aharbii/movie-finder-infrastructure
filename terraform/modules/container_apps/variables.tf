variable "resource_group_name"      { type = string }
variable "location"                  { type = string }
variable "environment"               { type = string }
variable "prefix"                    { type = string }
variable "infrastructure_subnet_id"  { type = string }
variable "acr_login_server"          { type = string }
variable "acr_admin_username"        { type = string; sensitive = true }
variable "acr_admin_password"        { type = string; sensitive = true }
variable "key_vault_id"              { type = string }
variable "backend_image_tag"         { type = string }
variable "frontend_image_tag"        { type = string }
variable "backend_min_replicas"      { type = number; default = 1 }
variable "backend_max_replicas"      { type = number; default = 3 }
variable "frontend_min_replicas"     { type = number; default = 1 }
variable "frontend_max_replicas"     { type = number; default = 3 }
variable "database_url"              { type = string; sensitive = true }
variable "tags"                      { type = map(string) }
