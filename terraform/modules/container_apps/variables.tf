variable "resource_group_name" {
  type        = string
  description = "Azure resource group name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "environment" {
  type        = string
  description = "Deployment environment token."
}

variable "prefix" {
  type        = string
  description = "Resource name prefix."
}

variable "infrastructure_subnet_id" {
  type        = string
  description = "Subnet ID for the Container Apps Environment."
}

variable "acr_login_server" {
  type        = string
  description = "Azure Container Registry login server."
}
variable "acr_admin_username" {
  type        = string
  description = "Azure Container Registry admin username."
  sensitive   = true
}
variable "acr_admin_password" {
  type        = string
  description = "Azure Container Registry admin password."
  sensitive   = true
}
variable "key_vault_id" {
  type        = string
  description = "Azure Key Vault ID used by backend managed identity."
}

variable "backend_image_tag" {
  type        = string
  description = "Backend image tag to deploy."
}

variable "frontend_image_tag" {
  type        = string
  description = "Frontend image tag to deploy."
}
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
  type        = string
  description = "Backend PostgreSQL connection URL."
  sensitive   = true
}
variable "classifier_provider" {
  type        = string
  description = "Classifier and confirmation chat provider."
}

variable "classifier_model" {
  type        = string
  description = "Classifier model."
}

variable "reasoning_provider" {
  type        = string
  description = "Reasoning and Q&A chat provider."
}

variable "reasoning_model" {
  type        = string
  description = "Reasoning and Q&A model."
}

variable "embedding_provider" {
  type        = string
  description = "Query embedding provider."
}

variable "embedding_model" {
  type        = string
  description = "Query embedding model."
}

variable "embedding_dimension" {
  type        = number
  description = "Query embedding dimension; must match RAG ingestion."
}

variable "vector_store" {
  type        = string
  description = "Query-time vector store provider."
}

variable "vector_collection_prefix" {
  type        = string
  description = "Dynamic vector target prefix. Final target is prefix_model_dimension."
}

variable "anthropic_api_key" {
  type        = string
  description = "Anthropic API key value used only to decide env injection."
  sensitive   = true
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI API key value used only to decide env injection."
  sensitive   = true
}

variable "groq_api_key" {
  type        = string
  description = "Groq API key value used only to decide env injection."
  sensitive   = true
}

variable "together_api_key" {
  type        = string
  description = "Together API key value used only to decide env injection."
  sensitive   = true
}

variable "google_api_key" {
  type        = string
  description = "Google API key value used only to decide env injection."
  sensitive   = true
}

variable "qdrant_url" {
  type        = string
  description = "Qdrant URL value used only to decide env injection."
  sensitive   = true
}

variable "qdrant_api_key_ro" {
  type        = string
  description = "Qdrant read-only API key value used only to decide env injection."
  sensitive   = true
}

variable "pinecone_api_key" {
  type        = string
  description = "Pinecone API key value used only to decide env injection."
  sensitive   = true
}

variable "pgvector_dsn" {
  type        = string
  description = "pgvector DSN value used only to decide env injection."
  sensitive   = true
}

variable "langsmith_api_key" {
  type        = string
  description = "LangSmith API key value used only to decide env injection."
  sensitive   = true
}

variable "langsmith_tracing" {
  type        = string
  description = "LangSmith tracing toggle."
}

variable "langsmith_endpoint" {
  type        = string
  description = "LangSmith API endpoint."
}

variable "langsmith_project" {
  type        = string
  description = "LangSmith project name."
}

variable "ollama_base_url" {
  type        = string
  description = "Ollama base URL when an Ollama provider is selected."
}

variable "chromadb_persist_path" {
  type        = string
  description = "ChromaDB persistence path when VECTOR_STORE=chromadb."
}

variable "pinecone_index_name" {
  type        = string
  description = "Pinecone index name when VECTOR_STORE=pinecone."
}

variable "pinecone_index_host" {
  type        = string
  description = "Optional Pinecone index host."
}

variable "pinecone_cloud" {
  type        = string
  description = "Pinecone serverless cloud."
}

variable "pinecone_region" {
  type        = string
  description = "Pinecone serverless region."
}

variable "cors_origins" {
  type        = string
  description = "Backend CORS origins as a JSON array string."
}

variable "global_rate_limit" {
  type        = string
  description = "Backend global SlowAPI fallback rate limit."
}

variable "auth_rate_limit" {
  type        = string
  description = "Backend auth route SlowAPI rate limit."
}

variable "chat_rate_limit" {
  type        = string
  description = "Backend chat route SlowAPI rate limit."
}

variable "max_message_length" {
  type        = number
  description = "Backend maximum accepted chat message length."
}

variable "pgvector_schema" {
  type        = string
  description = "PostgreSQL schema token for pgvector targets."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to module resources."
}
