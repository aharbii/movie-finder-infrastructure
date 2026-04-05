# Changelog

All notable changes to `movie-finder-infrastructure` are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added

- `docs/qdrant-secret-model.md` — authoritative reference for the Qdrant RO/RW access
  tier model, Azure Key Vault secret names, Jenkins credential IDs, and the full
  cross-repo environment variable contract for workstream #35
  ([infrastructure#8](https://github.com/aharbii/movie-finder-infrastructure/issues/8),
  [movie-finder#35](https://github.com/aharbii/movie-finder/issues/35))

- Terraform IaC scaffold for multi-cloud deployment (Azure primary, AWS/GCP extensible):
  - `terraform/providers.tf` — `azurerm ~> 4.0`, `aws ~> 5.0`, `google ~> 6.0` (AWS/GCP
    disabled by default via `enable_aws`/`enable_gcp` toggle variables); remote state
    backend on Azure Storage Account
  - `terraform/modules/networking` — VNet, app/db subnets with delegations, private DNS
  - `terraform/modules/container_registry` — Azure Container Registry (`azurerm_container_registry`)
  - `terraform/modules/key_vault` — Azure Key Vault with managed secrets; `lifecycle
    { ignore_changes = [value] }` so secret rotation bypasses Terraform
  - `terraform/modules/database` — PostgreSQL Flexible Server with `prevent_destroy = true`,
    HA for production, `BTREE_GIN` and `PG_TRGM` extensions
  - `terraform/modules/container_apps` — Azure Container Apps Environment + user-assigned
    managed identity for Key Vault access; backend and frontend Container Apps with HTTP
    scale rules and liveness/readiness probes; `lifecycle { ignore_changes = [image] }` so
    pipeline image updates don't conflict with Terraform state
  - `terraform/environments/staging.tfvars` and `production.tfvars` — environment configs
  - `terraform/scripts/bootstrap-state.sh` — one-time remote state storage bootstrap
  - `terraform/.gitignore` — standard Terraform ignores including `terraform.tfvars` (secrets)

### Changed

- `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `.github/copilot-instructions.md` — updated
  Jenkins credential IDs to reflect the new `qdrant-api-key-ro` / `qdrant-api-key-rw`
  split; clarified that `rag_ingestion` is an offline CI pipeline, not an Azure
  Container App
- Provisioning responsibility moved from `movie-finder-backend` and per-repo Jenkinsfiles
  to this repo; `infrastructure/` is now the single source of truth for all Azure resources
