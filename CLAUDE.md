# Claude Code — infrastructure submodule

This is **`movie-finder-infrastructure`** (`infrastructure/`) — part of the Movie Finder project.
GitHub repo: `aharbii/movie-finder-infrastructure` · Parent repo: `aharbii/movie-finder`

---

## What this submodule does

IaC and Azure provisioning for Movie Finder.

> **Status:** Terraform/Bicep implementation is not yet complete (tracked as issue #22).
> Read the current state of this directory before making assumptions about what exists.

Intended scope:
- Azure Container Apps (backend + frontend)
- Azure Container Registry (Docker image storage)
- Azure Key Vault (runtime secrets via managed identity — never baked into images)
- Azure Database for PostgreSQL Flexible Server
- Networking, RBAC, and managed identity configuration

---

## Full project context

### Submodule map

| Path | GitHub repo | Role |
|---|---|---|
| `.` (root) | `aharbii/movie-finder` | Parent — all cross-repo issues |
| `backend/` | `aharbii/movie-finder-backend` | FastAPI + uv workspace root |
| `backend/app/` | (nested in backend) | FastAPI application layer |
| `backend/chain/` | `aharbii/movie-finder-chain` | LangGraph AI pipeline |
| `backend/imdbapi/` | `aharbii/imdbapi-client` | Async IMDb REST client |
| `backend/rag_ingestion/` | `aharbii/movie-finder-rag` | Offline embedding ingestion |
| `frontend/` | `aharbii/movie-finder-frontend` | Angular 21 SPA |
| `docs/` | `aharbii/movie-finder-docs` | MkDocs documentation |
| `infrastructure/` | `aharbii/movie-finder-infrastructure` | **← you are here** |

### CI/CD pipeline

Jenkins Multibranch Pipelines push to Azure Container Registry; Azure Container Apps pulls from ACR.

| Pipeline mode | Trigger | Stages |
|---|---|---|
| CONTRIBUTION | Feature branch / PR | Lint · Test |
| INTEGRATION | Push to `main` | Lint · Test · Build Docker · Push `:sha8` + `:latest` → ACR |
| RELEASE | `v*` tag | Lint · Test · Build · Push `:v1.2.3` → ACR · Production deploy (manual approval) |

---

## Secrets and credentials architecture

**Where secrets live:**

| Secret type | Location | Who manages |
|---|---|---|
| Runtime API keys (Anthropic, OpenAI, Qdrant) | Azure Key Vault | User — manually |
| Database password | Azure Key Vault | User — manually |
| JWT signing key (`APP_SECRET_KEY`) | Azure Key Vault | User — manually |
| CI build credentials (API keys for tests) | Jenkins credentials store | User — manually (via Jenkins UI) |
| Container registry login | ACR managed identity | Azure — automatic |
| Key Vault access | Container App managed identity | Azure — automatic |

**Rules:**
- Never pass secrets through Jenkins build logs
- Never bake secrets into Docker images
- Never commit `.env` or any secret file — `detect-secrets` hook enforces this
- Rotate secrets via Key Vault, not by editing pipelines
- See `docs/devops-setup.md §12` for the Key Vault rotation workflow

**When adding a new secret:**
1. Add to Azure Key Vault manually
2. Reference it in the Container App environment via managed identity binding
3. Add to Jenkins credentials store (if needed at CI time)
4. Update `docs/devops-setup.md` credentials table
5. Update `.env.example` in every affected repo
6. Flag all of the above steps explicitly to the user — none are automatable by Claude

---

## Jenkins credential IDs

See `docs/devops-setup.md §9` for the full credential table. Common IDs:
- `qdrant-endpoint`, `qdrant-api-key`
- `openai-api-key`, `anthropic-api-key`
- `kaggle-username`, `kaggle-key`
- `app-secret-key`

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

## Session start protocol

1. `gh issue list --repo aharbii/movie-finder --state open`
2. Verify issue #22 status before starting IaC work — check what currently exists
3. Inspect `.github/ISSUE_TEMPLATE/*.yml`, `.github/PULL_REQUEST_TEMPLATE.md` when present, and a
   recent example of the same type
4. Create the parent issue in `aharbii/movie-finder`, then the linked child issue in
   `aharbii/movie-finder-infrastructure` only if this repo will actually change
5. Create a branch from `main` and work through the checklist

---

## Branching and commits

```
feature/<kebab>  chore/<kebab>  fix/<kebab>
```

Conventional Commits: `chore(infra): add Key Vault secret for Gemini API key`

---

## Cross-cutting change checklist

### 1. GitHub issues
- [ ] `aharbii/movie-finder` (parent)
- [ ] `aharbii/movie-finder-infrastructure` linked child issue only if this repo changes
- [ ] Matching issue/PR templates and a recent example were inspected before filing or editing

### 2. Branch
- [ ] Branch in this repo + `chore/` in root `movie-finder` to bump pointer
- [ ] New standalone issues branch from `main` unless stacking is explicitly requested

### 3. ADR
- [ ] New Azure service, new cloud provider, or new secrets architecture decision?
  → `docs/architecture/decisions/ADR-NNN-title.md`

### 4. Implementation
- [ ] IaC files updated (Terraform / Bicep — check what currently exists)
- [ ] No secrets or credentials in IaC source code
- [ ] Changes are idempotent (apply twice = same result)

### 5. Secrets and environment — flag ALL of the following to the user
- [ ] New Azure Key Vault secrets needed → list them explicitly; user adds manually
- [ ] New Jenkins credential IDs needed → list them; user adds via Jenkins UI
- [ ] New GitHub Secrets needed → list them; user adds via `gh secret set` or GitHub UI
- [ ] `.env.example` updated in **every affected repo**: root, `backend/`, `backend/chain/`, `backend/rag_ingestion/`, `frontend/`
- [ ] `docs/devops-setup.md` credentials table updated

### 6. CI — Jenkins
- [ ] `.github/workflows/*.yml` and/or Jenkinsfile reviewed for new credentials, permissions, or deploy steps
- [ ] Jenkins pipeline mode (INTEGRATION / RELEASE) still valid for new resources?

### 7. Architecture diagrams (in `docs/` submodule)
- [ ] **PlantUML** — `10-deployment-azure.puml` updated for any new Azure resources
  **Never generate `.mdj`** — user syncs to StarUML manually
- [ ] **Structurizr C4** — `workspace.dsl` deployment view updated
- [ ] Commit to `aharbii/movie-finder-docs` first

### 8. Documentation
- [ ] `docs/devops-setup.md` updated (new resources, access patterns, credentials)
- [ ] `CHANGELOG.md` under `[Unreleased]`
- [ ] Contributor docs updated when CI, required checks, or merge policy change

### 9. Sibling submodules affected
| Submodule | Why |
|---|---|
| All submodules | New env vars → `.env.example` updates everywhere |
| `backend/` | New Azure services may require new SDK deps or config |
| `docs/` | DevOps docs, deployment diagram, ADR |

### 10. Submodule pointer bump
```bash
# in root movie-finder
git add infrastructure && git commit -m "chore(infra): bump to latest main"
```

### 11. Pull request
- [ ] PR in `aharbii/movie-finder-infrastructure` discloses the AI authoring tool + model
- [ ] PR in `aharbii/movie-finder` (pointer bump)
- [ ] Any AI-assisted review comment or approval discloses the review tool + model
