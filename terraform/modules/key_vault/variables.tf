variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "prefix"              { type = string }
variable "sku_name"            { type = string }
variable "tags"                { type = map(string) }
variable "secrets" {
  type        = map(string)
  sensitive   = true
  description = "Map of secret name → value. Secrets with empty values are skipped."
}
