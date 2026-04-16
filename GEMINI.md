# Gemini CLI — infrastructure submodule

Foundational mandate for `movie-finder-infrastructure` (`infrastructure/`).

---

## What this submodule does

Terraform-first IaC for Azure resources consumed by Movie Finder.

- Azure networking, ACR, Key Vault, PostgreSQL Flexible Server, and Container Apps
- Repo-local Docker tooling for Terraform validation and pre-commit checks
- Secret naming and credential contract documentation

Application deployment still happens in the parent `movie-finder` repository via
the unified Jenkins pipeline. Do not move deployment orchestration into this
repo unless explicitly asked.

---

## Local tooling contract

Contributor workflow in this repo is **Docker-only** from the repo root.

- `make init`
- `make editor-up`
- `make shell`
- `make fmt`
- `make validate`
- `make tflint`
- `make pre-commit`
- `make check`
- `make ci-down`

---

## Secrets policy

- **No secrets in code.** `detect-secrets` is part of the repo contract.
- **Azure Key Vault** stores runtime secrets.
- **Jenkins credentials** store CI-only secrets.
- `rag_ingestion` remains an offline CI pipeline, never an Azure Container App.
- See `docs/qdrant-secret-model.md` for the authoritative secret-name and env-var contract.
- Update downstream `.env.example` files only when the actual secret contract changes.

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
- If the infrastructure contract changes, update the parent docs repo only when the change is
  actually user-facing or operationally required. Do not touch MkDocs content gratuitously.
- If a new standalone issue appears mid-session, branch from `main` unless stacking is explicitly
  requested.
- PR descriptions must disclose the AI authoring tool + model. Any AI-assisted review comment or
  approval must also disclose the review tool + model.

---

## VS Code setup

`infrastructure/.vscode/` is intentionally aligned with the Docker-only workflow.

- `settings.json` — Terraform formatter, YAML formatting, and attached-container defaults
- `tasks.json` — host tasks that call `make <target>`
- `extensions.json` — Remote Containers, Terraform, Azure, Docker, Makefile, and YAML support

**Interpreter workflow:** run `make editor-up`, then attach VS Code to the running
`infra` service container from this repo.

**Modifying VS Code configs:** update `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, and
the repo's `.github/copilot-instructions.md` after.
