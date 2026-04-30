# =============================================================================
# module: container_apps
# Azure Container Apps Environment + backend and frontend apps.
# =============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.prefix}-logs-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "production" ? 90 : 30
  tags                = var.tags
}

resource "azurerm_container_app_environment" "main" {
  name                       = "${var.prefix}-env-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id   = var.infrastructure_subnet_id
  tags                       = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Backend — FastAPI application
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_user_assigned_identity" "backend" {
  name                = "${var.prefix}-backend-identity-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "backend" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_user_assigned_identity.backend.tenant_id
  object_id    = azurerm_user_assigned_identity.backend.principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_container_app" "backend" {
  name                         = "${var.prefix}-backend-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.backend.id]
  }

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }

  template {
    min_replicas = var.backend_min_replicas
    max_replicas = var.backend_max_replicas

    container {
      name   = "backend"
      image  = "${var.acr_login_server}/movie-finder-backend:${var.backend_image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "APP_ENV"
        value = var.environment
      }
      env {
        name  = "DATABASE_URL"
        value = var.database_url
      }
      env {
        name        = "APP_SECRET_KEY"
        secret_name = "app-secret-key"
      }
      env {
        name  = "CLASSIFIER_PROVIDER"
        value = var.classifier_provider
      }
      env {
        name  = "CLASSIFIER_MODEL"
        value = var.classifier_model
      }
      env {
        name  = "REASONING_PROVIDER"
        value = var.reasoning_provider
      }
      env {
        name  = "REASONING_MODEL"
        value = var.reasoning_model
      }
      env {
        name  = "EMBEDDING_PROVIDER"
        value = var.embedding_provider
      }
      env {
        name  = "EMBEDDING_MODEL"
        value = var.embedding_model
      }
      env {
        name  = "EMBEDDING_DIMENSION"
        value = tostring(var.embedding_dimension)
      }
      env {
        name  = "VECTOR_STORE"
        value = var.vector_store
      }
      env {
        name  = "VECTOR_COLLECTION_PREFIX"
        value = var.vector_collection_prefix
      }
      env {
        name  = "OLLAMA_BASE_URL"
        value = var.ollama_base_url
      }
      env {
        name  = "CHROMADB_PERSIST_PATH"
        value = var.chromadb_persist_path
      }
      env {
        name  = "PINECONE_INDEX_NAME"
        value = var.pinecone_index_name
      }
      env {
        name  = "PINECONE_INDEX_HOST"
        value = var.pinecone_index_host
      }
      env {
        name  = "PINECONE_CLOUD"
        value = var.pinecone_cloud
      }
      env {
        name  = "PINECONE_REGION"
        value = var.pinecone_region
      }
      env {
        name  = "PGVECTOR_SCHEMA"
        value = var.pgvector_schema
      }
      env {
        name  = "LANGSMITH_TRACING"
        value = var.langsmith_tracing
      }
      env {
        name  = "LANGSMITH_ENDPOINT"
        value = var.langsmith_endpoint
      }
      env {
        name  = "LANGSMITH_PROJECT"
        value = var.langsmith_project
      }
      env {
        name  = "CORS_ORIGINS"
        value = var.cors_origins
      }
      env {
        name  = "GLOBAL_RATE_LIMIT"
        value = var.global_rate_limit
      }
      env {
        name  = "AUTH_RATE_LIMIT"
        value = var.auth_rate_limit
      }
      env {
        name  = "CHAT_RATE_LIMIT"
        value = var.chat_rate_limit
      }
      env {
        name  = "MAX_MESSAGE_LENGTH"
        value = tostring(var.max_message_length)
      }

      dynamic "env" {
        for_each = nonsensitive(var.anthropic_api_key) == "" ? [] : [1]
        content {
          name        = "ANTHROPIC_API_KEY"
          secret_name = "anthropic-api-key"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.openai_api_key) == "" ? [] : [1]
        content {
          name        = "OPENAI_API_KEY"
          secret_name = "openai-api-key"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.groq_api_key) == "" ? [] : [1]
        content {
          name        = "GROQ_API_KEY"
          secret_name = "groq-api-key"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.together_api_key) == "" ? [] : [1]
        content {
          name        = "TOGETHER_API_KEY"
          secret_name = "together-api-key"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.google_api_key) == "" ? [] : [1]
        content {
          name        = "GOOGLE_API_KEY"
          secret_name = "google-api-key"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.qdrant_url) == "" ? [] : [1]
        content {
          name        = "QDRANT_URL"
          secret_name = "qdrant-url"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.qdrant_api_key_ro) == "" ? [] : [1]
        content {
          name        = "QDRANT_API_KEY_RO"
          secret_name = "qdrant-api-key-ro"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.pinecone_api_key) == "" ? [] : [1]
        content {
          name        = "PINECONE_API_KEY"
          secret_name = "pinecone-api-key"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.pgvector_dsn) == "" ? [] : [1]
        content {
          name        = "PGVECTOR_DSN"
          secret_name = "pgvector-dsn"
        }
      }
      dynamic "env" {
        for_each = nonsensitive(var.langsmith_api_key) == "" ? [] : [1]
        content {
          name        = "LANGSMITH_API_KEY"
          secret_name = "langsmith-api-key"
        }
      }

      liveness_probe {
        path                    = "/health/live"
        port                    = 8000
        transport               = "HTTP"
        initial_delay           = 15
        interval_seconds        = 30
        failure_count_threshold = 3
      }

      readiness_probe {
        path      = "/health/ready"
        port      = 8000
        transport = "HTTP"
      }
    }

    http_scale_rule {
      name                = "http-scaler"
      concurrent_requests = "20"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]

    precondition {
      condition     = !contains([var.classifier_provider, var.reasoning_provider], "anthropic") || nonsensitive(var.anthropic_api_key) != ""
      error_message = "ANTHROPIC_API_KEY is required when CLASSIFIER_PROVIDER or REASONING_PROVIDER is anthropic."
    }
    precondition {
      condition     = !contains([var.classifier_provider, var.reasoning_provider, var.embedding_provider], "openai") || nonsensitive(var.openai_api_key) != ""
      error_message = "OPENAI_API_KEY is required when CLASSIFIER_PROVIDER, REASONING_PROVIDER, or EMBEDDING_PROVIDER is openai."
    }
    precondition {
      condition     = !contains([var.classifier_provider, var.reasoning_provider], "groq") || nonsensitive(var.groq_api_key) != ""
      error_message = "GROQ_API_KEY is required when CLASSIFIER_PROVIDER or REASONING_PROVIDER is groq."
    }
    precondition {
      condition     = !contains([var.classifier_provider, var.reasoning_provider], "together") || nonsensitive(var.together_api_key) != ""
      error_message = "TOGETHER_API_KEY is required when CLASSIFIER_PROVIDER or REASONING_PROVIDER is together."
    }
    precondition {
      condition     = !contains([var.classifier_provider, var.reasoning_provider, var.embedding_provider], "google") || nonsensitive(var.google_api_key) != ""
      error_message = "GOOGLE_API_KEY is required when CLASSIFIER_PROVIDER, REASONING_PROVIDER, or EMBEDDING_PROVIDER is google."
    }
    precondition {
      condition     = var.vector_store != "qdrant" || (nonsensitive(var.qdrant_url) != "" && nonsensitive(var.qdrant_api_key_ro) != "")
      error_message = "QDRANT_URL and QDRANT_API_KEY_RO are required when VECTOR_STORE is qdrant."
    }
    precondition {
      condition     = var.vector_store != "pinecone" || nonsensitive(var.pinecone_api_key) != ""
      error_message = "PINECONE_API_KEY is required when VECTOR_STORE is pinecone."
    }
    precondition {
      condition     = var.vector_store != "pgvector" || nonsensitive(var.pgvector_dsn) != ""
      error_message = "PGVECTOR_DSN is required when VECTOR_STORE is pgvector."
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Frontend — Angular SPA served by nginx
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_container_app" "frontend" {
  name                         = "${var.prefix}-frontend-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }

  template {
    min_replicas = var.frontend_min_replicas
    max_replicas = var.frontend_max_replicas

    container {
      name   = "frontend"
      image  = "${var.acr_login_server}/movie-finder-frontend:${var.frontend_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "BACKEND_URL"
        value = "https://${azurerm_container_app.backend.latest_revision_fqdn}"
      }

      liveness_probe {
        path                    = "/"
        port                    = 80
        transport               = "HTTP"
        initial_delay           = 5
        interval_seconds        = 30
        failure_count_threshold = 3
      }
    }

    http_scale_rule {
      name                = "http-scaler"
      concurrent_requests = "50"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }
}
