# GitHub Copilot — movie-finder-infrastructure

Terraform-first Azure Infrastructure as Code for Movie Finder.

This repo owns the infrastructure definitions and the repo-local validation
workflow. The parent `aharbii/movie-finder` repository still owns the unified
Jenkins deployment pipeline that rolls out backend and frontend together.

---

## What exists here

- `terraform/` for Azure networking, ACR, Key Vault, PostgreSQL, and Container Apps
- `Dockerfile`, `docker-compose.yml`, and `Makefile` for Docker-only local validation
- `.pre-commit-config.yaml` and `.secrets.baseline` for file-health and secret checks
- `.vscode/` tasks/settings aligned with the attached-container workflow

---

## Local workflow

Use the repo root and prefer the committed commands:

- `make init`
- `make editor-up`
- `make fmt`
- `make validate`
- `make tflint`
- `make pre-commit`
- `make check`

Do not assume host-installed Terraform, TFLint, or pre-commit.

---

## Secrets model

- Runtime secrets live in Azure Key Vault
- CI secrets live in Jenkins credentials
- Secrets are never committed, baked into images, or passed through CI logs
- `rag_ingestion` remains an offline CI pipeline and is never an Azure Container App
- `docs/qdrant-secret-model.md` is the authoritative contract for secret names and env vars

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
- Update the parent docs repo only when the infrastructure contract actually changes; do not touch
  MkDocs content gratuitously.
- PR descriptions must disclose the AI authoring tool + model. Any AI-assisted review comment or
  approval must also disclose the review tool + model.
