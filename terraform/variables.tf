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
  description = "OpenAI API key for embeddings."
  sensitive   = true
}

variable "anthropic_api_key" {
  type        = string
  description = "Anthropic API key for Claude models."
  sensitive   = true
}

variable "qdrant_url" {
  type        = string
  description = "Qdrant Cloud endpoint URL."
  sensitive   = true
}

variable "qdrant_api_key_ro" {
  type        = string
  description = "Qdrant read-only API key."
  sensitive   = true
}

variable "langsmith_api_key" {
  type        = string
  description = "LangSmith API key (optional — leave empty to disable tracing)."
  sensitive   = true
  default     = ""
}

# ─────────────────────────────────────────────────────────────────────────────
# AWS — disabled by default
# ─────────────────────────────────────────────────────────────────────────────

variable "enable_aws" {
  type        = bool
  description = "Set to true to provision AWS resources instead of / in addition to Azure."
  default     = false
}

variable "aws_region" {
  type        = string
  description = "AWS region for optional resource provisioning."
  default     = "us-east-1"
}

# ─────────────────────────────────────────────────────────────────────────────
# GCP — disabled by default
# ─────────────────────────────────────────────────────────────────────────────

variable "enable_gcp" {
  type        = bool
  description = "Set to true to provision GCP resources instead of / in addition to Azure."
  default     = false
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID for optional resource provisioning."
  default     = ""
}

variable "gcp_region" {
  type        = string
  description = "GCP region for optional resource provisioning."
  default     = "us-central1"
}
