# Claude Code — infrastructure submodule

This is **`movie-finder-infrastructure`** (`infrastructure/`) — part of the
Movie Finder project.
GitHub repo: `aharbii/movie-finder-infrastructure` · Parent repo: `aharbii/movie-finder`

---

## What this submodule does

Terraform-first IaC for the Azure resources consumed by Movie Finder.

Current scope:

- Azure networking for app and database subnets
- Azure Container Registry
- Azure Key Vault for runtime secrets
- Azure Database for PostgreSQL Flexible Server
- Azure Container Apps environment and app definitions
- Repo-local Docker tooling for Terraform validation and pre-commit checks

---

## Current ownership boundary

- This repo owns the infrastructure definitions and validation workflow.
- The parent `movie-finder` repo owns the unified Jenkins pipeline that deploys
  backend and frontend together.
- This repo is consumed there as the `infrastructure/` submodule; after infra
  changes merge here, the parent repo must bump the submodule pointer.
- Do not move runtime deployment logic from the parent repo into this repo
  unless explicitly asked.

---

## Full project context

### Submodule map

| Path                     | GitHub repo                           | Role                           |
| ------------------------ | ------------------------------------- | ------------------------------ |
| `.` (root)               | `aharbii/movie-finder`                | Parent — all cross-repo issues |
| `backend/`               | `aharbii/movie-finder-backend`        | FastAPI + uv workspace root    |
| `backend/app/`           | (nested in backend)                   | FastAPI application layer      |
| `backend/chain/`         | `aharbii/movie-finder-chain`          | LangGraph AI pipeline          |
| `backend/chain/imdbapi/` | `aharbii/imdbapi-client`              | Async IMDb REST client         |
| `backend/rag_ingestion/` | `aharbii/movie-finder-rag`            | Offline embedding ingestion    |
| `frontend/`              | `aharbii/movie-finder-frontend`       | Angular SPA                    |
| `docs/`                  | `aharbii/movie-finder-docs`           | MkDocs documentation           |
| `infrastructure/`        | `aharbii/movie-finder-infrastructure` | **← you are here**             |

### CI / deployment boundary

- GitHub Actions in this repo validate Terraform formatting, initialization, and TFLint.
- The parent `movie-finder` repo's unified Jenkinsfile performs runtime build and deployment.
- If an infrastructure change requires downstream documentation, update the parent docs repo
  only when the change is actually user-facing or operationally necessary.

---

## Local contributor workflow

Contributor workflow in this repo is **strictly Docker-only** from the repo root.

### Commands

- `make init` — build tooling image and install the git pre-commit hook
- `make editor-up` / `make editor-down` — start or stop the long-lived tooling container
- `make shell` — open a shell in the tooling container
- `make fmt` / `make fmt-check` — run Terraform formatting
- `make validate` — run `terraform init -backend=false -reconfigure && terraform validate`
- `make tflint` — run `tflint --init && tflint --format compact`
- `make pre-commit` — run the full local hook suite
- `make check` — CI-aligned validation gate (`fmt-check + validate + tflint`)

### VS Code

Run `make editor-up`, then use `Dev Containers: Attach to Running Container...`
and attach to the `infra` service container.

Committed workspace files:

- `.vscode/settings.json` — Terraform formatter, YAML formatter, attached-container defaults
- `.vscode/tasks.json` — `make ...` task surface
- `.vscode/extensions.json` — Remote Containers, Terraform, Azure, Docker, Makefile, YAML

If you modify `.vscode/`, also update `AGENTS.md`, `GEMINI.md`, and
`.github/copilot-instructions.md`.

---

## Secrets and credentials architecture

**Where secrets live:**

| Secret type                                  | Location                  | Who manages                      |
| -------------------------------------------- | ------------------------- | -------------------------------- |
| Runtime API keys and app secrets             | Azure Key Vault           | User — manually                  |
| CI build credentials                         | Jenkins credentials store | User — manually                  |
| Container registry and Key Vault access      | Azure managed identity    | Azure — automatic                |

**Rules:**

- Never commit secrets or `.env` files
- Never bake secrets into Docker images
- Never pass secrets through CI logs
- Rotate runtime secrets in Key Vault, not through git
- See `docs/qdrant-secret-model.md` for the authoritative secret-name contract

When adding a new secret:

1. Add it to Azure Key Vault manually
2. Add CI credentials manually if the pipeline needs it
3. Update downstream `.env.example` files only if the actual contract changes
4. Flag all manual steps explicitly in the PR description or issue thread

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
2. Verify the relevant infra issue/PR status before starting work
3. Inspect `.github/ISSUE_TEMPLATE/*.yml`, `.github/PULL_REQUEST_TEMPLATE.md`, and a recent example
4. Create the parent issue in `aharbii/movie-finder`, then the linked child issue here only if
   this repo will actually change
5. Create a branch from `main` unless stacked work is explicitly intended

---

## Cross-cutting change checklist

| #   | Category     | Key gate                                                                                              |
| --- | ------------ | ----------------------------------------------------------------------------------------------------- |
| 1   | **Issues**   | Parent `aharbii/movie-finder` issue exists; child issue here only if this repo changes               |
| 2   | **Branch**   | `feature/`, `fix/`, or `chore/` branch in this repo; root repo pointer bump follows after merge      |
| 3   | **IaC**      | No secrets in source; Terraform validation passes; changes are idempotent                            |
| 4   | **Secrets**  | New manual Key Vault / Jenkins steps explicitly called out                                            |
| 5   | **CI**       | GitHub Actions validation still reflects the local `make check` contract                              |
| 6   | **Docs**     | `CHANGELOG.md` updated; parent docs repo touched only when the infrastructure contract actually needs it |
| 7   | **Pointer**  | Parent `movie-finder` submodule pointer updated after infra merge or stacked branch refresh           |

### Submodule pointer bump

```bash
# in root movie-finder
git add infrastructure && git commit -m "chore(infra): bump to latest main"
```
