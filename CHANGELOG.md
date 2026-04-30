# Changelog

All notable changes to `movie-finder-infrastructure` are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added

- Terraform variables and Container App environment wiring for ADR 0008 chain
  runtime selection: classifier/reasoning providers and models, embedding provider
  and dimension, vector-store provider, dynamic collection prefix, and
  provider-specific Ollama/ChromaDB/Qdrant/Pinecone/pgvector settings
- Azure Key Vault secret slots for optional cloud providers: Groq, Together,
  Google, Pinecone, pgvector, Qdrant RO/RW, and LangSmith
- `docs/provider-runtime-contract.md` — authoritative reference for provider
  runtime selection, vector-store settings, Azure Key Vault secret names,
  Jenkins credential IDs, and the full cross-repo environment variable contract
  ([infrastructure#8](https://github.com/aharbii/movie-finder-infrastructure/issues/8),
  [movie-finder#35](https://github.com/aharbii/movie-finder/issues/35))

- Docker-first local tooling for infrastructure contributors:
  - `Dockerfile`, `docker-compose.yml`, `Makefile` — repo-local Terraform, TFLint,
    pre-commit, and attached-container workflows
  - `.pre-commit-config.yaml` and `.secrets.baseline` — file-health, detect-secrets,
    Terraform fmt/validate, and TFLint checks
  - `.vscode/tasks.json` plus refreshed workspace settings/extensions — attached-container
    workflow and `make ...` task surface aligned with the rest of `movie-finder`

- Terraform IaC scaffold for Azure deployment:
  - `terraform/providers.tf` — `azurerm ~> 4.0`; remote state backend on Azure Storage Account
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

- Secret-model documentation is now the provider/vector-store runtime contract
  and uses the canonical provider-runtime filename
- Container Apps module variables now include descriptions for terraform-docs
  consumers
- Container Apps now validates selected provider/vector-store secrets before
  deploy and injects only the configured optional provider secrets
- `README.md`, `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `.github/copilot-instructions.md`,
  `.junie/guidelines.md`, and `ai-context/*` — refreshed to describe the Docker-only local
  tooling contract, attached-container VS Code workflow, and the parent-repo Jenkins
  deployment boundary
- Terraform formatting and provider metadata were refreshed to match the current Azure-only
  module surface and CI expectations
- `terraform/modules/container_apps/main.tf` — corrected Azure Container Apps probe field
  names so local validation matches the provider schema
- Provisioning responsibility moved from `movie-finder-backend` and per-repo Jenkinsfiles
  to this repo; `infrastructure/` is now the single source of truth for all Azure resources
