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
| `backend/chain/imdbapi/` | `aharbii/imdbapi-client` | Async IMDb REST client |
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

See `docs/qdrant-secret-model.md` for the full cross-repo secret contract and the
authoritative mapping of credential IDs to env var names. Key IDs:

- `qdrant-url`, `qdrant-api-key-ro`, `qdrant-api-key-rw`, `qdrant-collection-name`
- `openai-api-key`, `anthropic-api-key`
- `kaggle-api-token`
- `app-secret-key`, `postgres-url`

> `qdrant-api-key-rw` is used exclusively by the `rag_ingestion` CI pipeline.
> `rag_ingestion` is an offline CI job — it is never deployed as an Azure Container App.
> Its secrets live in the Jenkins credentials store only, not in Azure Key Vault.

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

Full detail in `ai-context/issue-agent-briefing-template.md`.

| # | Category | Key gate |
|---|---|---|
| 1 | **Issues** | Parent `aharbii/movie-finder` + child here only if this repo changes; templates inspected |
| 2 | **Branch** | `feature/fix/chore` in this repo + pointer-bump `chore/` in root `movie-finder` |
| 3 | **ADR** | New Azure service, cloud provider, or secrets architecture decision → ADR in `docs/` |
| 4 | **IaC** | No secrets in source; changes are idempotent; Terraform/Bicep validate passes |
| 5 | **Secrets** | List ALL new Key Vault secrets, Jenkins credentials, GitHub Secrets explicitly — user adds manually; `.env.example` updated in every affected repo; `docs/devops-setup.md` updated |
| 6 | **CI** | `Jenkinsfile` reviewed; INTEGRATION/RELEASE pipeline mode still valid |
| 7 | **Diagrams** | `10-deployment-azure.puml` updated; `workspace.dsl` deployment view updated; commit to `docs/` first; **never `.mdj`** |
| 8 | **Docs** | `docs/devops-setup.md` updated; `CHANGELOG.md` updated |

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
