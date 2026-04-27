variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "prefix" { type = string }
variable "infrastructure_subnet_id" { type = string }
variable "acr_login_server" { type = string }
variable "acr_admin_username" {
  type      = string
  sensitive = true
}
variable "acr_admin_password" {
  type      = string
  sensitive = true
}
variable "key_vault_id" { type = string }
variable "backend_image_tag" { type = string }
variable "frontend_image_tag" { type = string }
variable "backend_min_replicas" {
  type    = number
  default = 1
}
variable "backend_max_replicas" {
  type    = number
  default = 3
}
variable "frontend_min_replicas" {
  type    = number
  default = 1
}
variable "frontend_max_replicas" {
  type    = number
  default = 3
}
variable "database_url" {
  type      = string
  sensitive = true
}
variable "classifier_provider" { type = string }
variable "classifier_model" { type = string }
variable "reasoning_provider" { type = string }
variable "reasoning_model" { type = string }
variable "embedding_provider" { type = string }
variable "embedding_model" { type = string }
variable "embedding_dimension" { type = number }
variable "vector_store" { type = string }
variable "vector_collection_prefix" { type = string }
variable "ollama_base_url" { type = string }
variable "chromadb_persist_path" { type = string }
variable "pinecone_index_name" { type = string }
variable "pinecone_index_host" { type = string }
variable "pinecone_cloud" { type = string }
variable "pinecone_region" { type = string }
variable "pgvector_schema" { type = string }
variable "tags" { type = map(string) }
