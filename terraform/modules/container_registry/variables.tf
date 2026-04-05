variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "prefix"              { type = string }
variable "sku"                 { type = string }
variable "admin_enabled"       { type = bool }
variable "tags"                { type = map(string) }
