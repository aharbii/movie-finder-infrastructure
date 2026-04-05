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

      liveness_probe {
        path             = "/health/live"
        port             = 8000
        transport        = "HTTP"
        initial_delay    = 15
        period_seconds   = 30
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
        path          = "/"
        port          = 80
        transport     = "HTTP"
        initial_delay = 5
        period_seconds = 30
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
