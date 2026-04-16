# JetBrains AI (Junie) — infrastructure submodule guidelines

This is **`movie-finder-infrastructure`** (`infrastructure/`) — Terraform-first
Azure infrastructure for Movie Finder.
GitHub repo: `aharbii/movie-finder-infrastructure` · Parent: `aharbii/movie-finder`

---

## What this submodule does

Terraform IaC for the Azure resources consumed by the application.

- `terraform/modules/networking`
- `terraform/modules/container_registry`
- `terraform/modules/key_vault`
- `terraform/modules/database`
- `terraform/modules/container_apps`

Application deployment remains owned by the parent `movie-finder` repository's
unified Jenkins pipeline. This repo owns definitions and validation, not the
runtime rollout orchestration.

---

## Local tooling contract

Use the committed Docker-first workflow from this repo root:

- `make init`
- `make editor-up`
- `make shell`
- `make fmt`
- `make validate`
- `make tflint`
- `make pre-commit`
- `make check`

Do not assume host-installed Terraform, TFLint, or pre-commit.

---

## Terraform standards

- `terraform fmt -check -recursive` must pass
- `terraform init -backend=false -reconfigure && terraform validate` must pass
- `tflint --init && tflint --format compact` must pass
- Remote state remains Azure Storage backed; do not commit `terraform.tfstate`
- No hardcoded secrets — runtime secrets belong in Key Vault, CI secrets in Jenkins
- `ignore_changes` on runtime-managed values is acceptable when justified

---

## Workflow

- Branches: `feature/<kebab>`, `fix/<kebab>`, `chore/<kebab>`
- Commits: `feat(infra): add Azure Container Apps environment`
- After infra changes land here, bump the `infrastructure/` submodule pointer in
  the parent `movie-finder` repo
- Update the parent docs repo only when the infrastructure contract actually changes

---

## Secret handling

All production secrets live in Azure Key Vault. Never commit secrets.
New secrets must be:

1. Added to Key Vault manually
2. Added to Jenkins credentials manually if CI needs them
3. Reflected in downstream `.env.example` files only when the contract changes
4. Called out explicitly in the PR or issue discussion
