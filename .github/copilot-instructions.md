# GitHub Copilot — movie-finder-infrastructure

Infrastructure as Code for Movie Finder on Azure. Provisions all Azure resources needed
to run the application: Container Apps, Container Registry, PostgreSQL, Key Vault, and
supporting services.

Parent project: `aharbii/movie-finder` — all issues created there first, then linked here.

Status: **Issue #22** — IaC not yet implemented. This repo is a placeholder.

---

## Target Azure architecture

| Resource | Purpose |
|---|---|
| Azure Container Registry (ACR) | Stores Docker images (backend + frontend) |
| Azure Container Apps | Runs backend (FastAPI) and frontend (nginx) |
| Azure Database for PostgreSQL | Managed PostgreSQL 16 |
| Azure Key Vault | Runtime secrets (API keys, DB password, JWT secret) |
| Managed Identity | Allows Container Apps to read Key Vault secrets without credentials in env |

Secrets are never baked into Docker images or passed through CI logs.
Production secrets live in Azure Key Vault, injected at runtime via managed identity.

---

## IaC toolchain

| Tool | Purpose |
|---|---|
| Terraform | Primary IaC (planned) |
| Bicep | Azure-native alternative (under evaluation) |
| `az` CLI | Ad-hoc operations and validation |

ADR required before committing to either Terraform or Bicep — see issue #22.

---

## VSCode extensions (installed in this workspace)

- `hashicorp.terraform`
- `ms-azuretools.vscode-bicep`
- `ms-azuretools.azure-resources`
- `ms-azuretools.vscode-docker`

---

## Cross-cutting — check for every change

1. GitHub issue in `aharbii/movie-finder` + this repo (linked)
2. Branch: `feature/`, `chore/` (kebab-case)
3. **ADR required** for any new Azure resource, cloud provider decision, or IaC toolchain choice
4. New secrets → update `.env.example` in all affected repos + flag for Key Vault + Jenkins credentials store
5. New Azure resources → update `docs/architecture/10-deployment-azure.puml` + Structurizr `workspace.dsl`
6. Cost implications → flag to project owner before merging
7. Changes committed here first, then submodule pointer bumped in parent repo (`aharbii/movie-finder`)
