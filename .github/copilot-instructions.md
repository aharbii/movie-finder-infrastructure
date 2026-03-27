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

`rag_ingestion` is an offline CI pipeline and is **never deployed as an Azure Container
App**. Its secrets (`qdrant-api-key-rw`, `openai-api-key`, `kaggle-*`) live in the Jenkins
credentials store only.

See `docs/qdrant-secret-model.md` for the authoritative credential ID → env var mapping
and the full cross-repo secret contract.

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

## Workflow invariants

- This repo is the gitlink path `infrastructure` inside `aharbii/movie-finder`. Parent
  workflow/path filters must use `infrastructure`, not `infrastructure/**`.
- Cross-repo tracker issues originate in `aharbii/movie-finder`. Create the linked child issue in
  this repo only if this repo will actually change.
- Inspect `.github/ISSUE_TEMPLATE/*.yml`, `.github/PULL_REQUEST_TEMPLATE.md` when present, and a
  recent example before creating or editing issues/PRs. Do not improvise titles or bodies.
- For child issues in this repo, use `.github/ISSUE_TEMPLATE/linked_task.yml` and keep the
  description, file references, and acceptance criteria repo-specific.
- If CI, required checks, or merge policy changes affect this repo, update contributor-facing docs
  here and in `aharbii/movie-finder` where relevant.
- If a new standalone issue appears mid-session, branch from `main` unless stacking is explicitly
  requested.
- PR descriptions must disclose the AI authoring tool + model. Any AI-assisted review comment or
  approval must also disclose the review tool + model.

---

## Cross-cutting — check for every change

1. GitHub issue in `aharbii/movie-finder` + linked child issue here only if this repo changes, using the current templates and recent examples
2. Branch: `feature/`, `chore/` (kebab-case) from `main` unless stacking is explicitly requested
3. **ADR required** for any new Azure resource, cloud provider decision, or IaC toolchain choice
4. New secrets → update `.env.example` in all affected repos + flag for Key Vault + Jenkins credentials store
5. New Azure resources → update `docs/architecture/10-deployment-azure.puml` + Structurizr `workspace.dsl`
6. Cost implications → flag to project owner before merging
7. Changes committed here first, then submodule pointer bumped in parent repo (`aharbii/movie-finder`)
