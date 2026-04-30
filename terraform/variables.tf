# =============================================================================
# movie-finder — Terraform input variables
# =============================================================================

# ─────────────────────────────────────────────────────────────────────────────
# Global
# ─────────────────────────────────────────────────────────────────────────────

variable "environment" {
  type        = string
  description = "Deployment environment: staging or production."
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment must be 'staging' or 'production'."
  }
}

variable "location" {
  type        = string
  description = "Primary Azure region, e.g. eastus."
  default     = "eastus"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all Azure resources."
  default     = {}
}

# ─────────────────────────────────────────────────────────────────────────────
# Azure
# ─────────────────────────────────────────────────────────────────────────────

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID."
  sensitive   = true
}

# ─────────────────────────────────────────────────────────────────────────────
# Container Registry
# ─────────────────────────────────────────────────────────────────────────────

variable "acr_sku" {
  type        = string
  description = "Azure Container Registry SKU: Basic, Standard, or Premium."
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "acr_admin_enabled" {
  type        = bool
  description = "Enable ACR admin user (required for Container Apps pull with username/password)."
  default     = false
}

# ─────────────────────────────────────────────────────────────────────────────
# Container Apps
# ─────────────────────────────────────────────────────────────────────────────

variable "backend_image_tag" {
  type        = string
  description = "Backend container image tag to deploy."
}

variable "frontend_image_tag" {
  type        = string
  description = "Frontend container image tag to deploy."
}

variable "backend_min_replicas" {
  type        = number
  description = "Minimum replica count for the backend Container App."
  default     = 1
}

variable "backend_max_replicas" {
  type        = number
  description = "Maximum replica count for the backend Container App."
  default     = 3
}

variable "frontend_min_replicas" {
  type        = number
  description = "Minimum replica count for the frontend Container App."
  default     = 1
}

variable "frontend_max_replicas" {
  type        = number
  description = "Maximum replica count for the frontend Container App."
  default     = 3
}

# ─────────────────────────────────────────────────────────────────────────────
# Database
# ─────────────────────────────────────────────────────────────────────────────

variable "db_admin_username" {
  type        = string
  description = "PostgreSQL administrator username."
  sensitive   = true
}

variable "db_admin_password" {
  type        = string
  description = "PostgreSQL administrator password."
  sensitive   = true
}

variable "db_sku_name" {
  type        = string
  description = "PostgreSQL Flexible Server SKU, e.g. B_Standard_B1ms."
  default     = "B_Standard_B1ms"
}

variable "db_storage_mb" {
  type        = number
  description = "PostgreSQL Flexible Server storage in MB."
  default     = 32768
}

variable "db_version" {
  type        = string
  description = "PostgreSQL version."
  default     = "16"
}

# ─────────────────────────────────────────────────────────────────────────────
# Key Vault
# ─────────────────────────────────────────────────────────────────────────────

variable "key_vault_sku" {
  type        = string
  description = "Key Vault SKU: standard or premium."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "key_vault_sku must be 'standard' or 'premium'."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Application secrets (injected into Key Vault; never logged or stored in state)
# ─────────────────────────────────────────────────────────────────────────────

variable "app_secret_key" {
  type        = string
  description = "FastAPI application secret key."
  sensitive   = true
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI API key when any selected provider is openai."
  sensitive   = true
  default     = ""
}

variable "anthropic_api_key" {
  type        = string
  description = "Anthropic API key when any selected chat provider is anthropic."
  sensitive   = true
  default     = ""
}

variable "groq_api_key" {
  type        = string
  description = "Groq API key for Groq-hosted chat models."
  sensitive   = true
  default     = ""
}

variable "together_api_key" {
  type        = string
  description = "Together API key for OpenAI-compatible chat models."
  sensitive   = true
  default     = ""
}

variable "google_api_key" {
  type        = string
  description = "Google API key for Gemini chat or embedding models."
  sensitive   = true
  default     = ""
}

variable "pinecone_api_key" {
  type        = string
  description = "Pinecone API key when VECTOR_STORE=pinecone."
  sensitive   = true
  default     = ""
}

variable "pgvector_dsn" {
  type        = string
  description = "pgvector PostgreSQL DSN when VECTOR_STORE=pgvector."
  sensitive   = true
  default     = ""
}

variable "qdrant_url" {
  type        = string
  description = "Qdrant Cloud endpoint URL."
  sensitive   = true
  default     = ""
}

variable "qdrant_api_key_ro" {
  type        = string
  description = "Qdrant read-only API key."
  sensitive   = true
  default     = ""
}

variable "qdrant_api_key_rw" {
  type        = string
  description = "Qdrant write-capable API key for RAG ingestion pipelines."
  sensitive   = true
  default     = ""
}

variable "langsmith_api_key" {
  type        = string
  description = "LangSmith API key (optional — leave empty to disable tracing)."
  sensitive   = true
  default     = ""
}

variable "langsmith_tracing" {
  type        = string
  description = "LangSmith tracing toggle: true or false."
  default     = "false"
}

variable "langsmith_endpoint" {
  type        = string
  description = "LangSmith API endpoint."
  default     = "https://api.smith.langchain.com"
}

variable "langsmith_project" {
  type        = string
  description = "LangSmith project name."
  default     = "movie-finder"
}

variable "cors_origins" {
  type        = string
  description = "Backend CORS origins as a JSON array string."
  default     = "[]"
}

variable "global_rate_limit" {
  type        = string
  description = "Backend global SlowAPI fallback rate limit."
  default     = "100/minute"
}

variable "auth_rate_limit" {
  type        = string
  description = "Backend auth route SlowAPI rate limit."
  default     = "5/minute"
}

variable "chat_rate_limit" {
  type        = string
  description = "Backend chat route SlowAPI rate limit."
  default     = "20/minute"
}

variable "max_message_length" {
  type        = number
  description = "Backend maximum accepted chat message length."
  default     = 2000
}

variable "classifier_provider" {
  type        = string
  description = "Classifier and confirmation chat provider."
  default     = "anthropic"
}

variable "classifier_model" {
  type        = string
  description = "Classifier model."
  default     = "claude-haiku-4-5-20251001"
}

variable "reasoning_provider" {
  type        = string
  description = "Reasoning and Q&A chat provider."
  default     = "anthropic"
}

variable "reasoning_model" {
  type        = string
  description = "Reasoning and Q&A model."
  default     = "claude-sonnet-4-6"
}

variable "embedding_provider" {
  type        = string
  description = "Query embedding provider."
  default     = "openai"
}

variable "embedding_model" {
  type        = string
  description = "Query embedding model."
  default     = "text-embedding-3-large"
}

variable "embedding_dimension" {
  type        = number
  description = "Query embedding dimension; must match RAG ingestion."
  default     = 3072
}

variable "vector_store" {
  type        = string
  description = "Query-time vector store provider."
  default     = "qdrant"
}

variable "vector_collection_prefix" {
  type        = string
  description = "Dynamic vector target prefix. Final target is prefix_model_dimension."
  default     = "movies"
}

variable "ollama_base_url" {
  type        = string
  description = "Ollama base URL when an Ollama provider is selected."
  default     = "http://localhost:11434"
}

variable "chromadb_persist_path" {
  type        = string
  description = "ChromaDB persistence path when VECTOR_STORE=chromadb."
  default     = "outputs/chromadb/local"
}

variable "pinecone_index_name" {
  type        = string
  description = "Pinecone index name when VECTOR_STORE=pinecone."
  default     = "movie-finder-rag"
}

variable "pinecone_index_host" {
  type        = string
  description = "Optional Pinecone index host."
  default     = ""
}

variable "pinecone_cloud" {
  type        = string
  description = "Pinecone serverless cloud."
  default     = "aws"
}

variable "pinecone_region" {
  type        = string
  description = "Pinecone serverless region."
  default     = "us-east-1"
}

variable "pgvector_schema" {
  type        = string
  description = "PostgreSQL schema token for pgvector targets."
  default     = "public"
}
