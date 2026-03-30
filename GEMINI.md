# Gemini CLI — infrastructure submodule

Foundational mandate for `movie-finder-infrastructure` (`infrastructure/`).

---

## What this submodule does
IaC (Terraform/Bicep) for Azure provisioning (ACR, Key Vault, Container Apps).

---

## Secrets policy
- **No secrets in code.** `detect-secrets` hook enforced.
- **Azure Key Vault** for runtime secrets (backend-app, chain Container Apps only).
- **Jenkins credentials store** for CI secrets (all pipelines, including rag_ingestion).
- `rag_ingestion` is an offline CI pipeline — never deployed to Azure. Its secrets
  (`qdrant-api-key-rw`, `openai-api-key`, `kaggle-api-token`) live in Jenkins only.
- See `docs/qdrant-secret-model.md` for the full cross-repo secret contract and
  authoritative credential ID → env var mapping.
- Update `.env.example` in all affected repos when adding secrets.

---

## Checklist for infra changes
- Idempotent IaC files.
- Update `docs/devops-setup.md` credentials table.
- Flag new secrets to user for manual addition to Key Vault/Jenkins.

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

## VSCode setup

`infrastructure/.vscode/` — workspace configuration for IaC editing.
- `settings.json`: Terraform/Bicep formatter placeholders (uncomment once issue #22 tooling is chosen)
- `extensions.json`: `hashicorp.terraform`, `ms-azuretools.vscode-bicep`, `ms-azuretools.azure-resources`, Docker, YAML
- Modifying configs: uncomment the relevant formatter block once IaC tooling is decided.
  Update `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, and the repo's `.github/copilot-instructions.md` after.
