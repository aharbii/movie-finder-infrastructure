# Movie Finder — Infrastructure

Terraform-first Azure Infrastructure as Code and local validation tooling for
the Movie Finder project.

> **Status:** The Terraform scaffold lives in [`terraform/`](terraform/), but
> runtime deployment of the backend and frontend still happens from the parent
> `movie-finder` repository's unified Jenkins pipeline. This repo owns the IaC
> definitions and the repo-local validation workflow; the parent repo consumes
> this repo as the `infrastructure/` submodule.

---

## What this repository owns

- Azure networking for the application environment
- Azure Container Registry (ACR)
- Azure Key Vault and the secret naming contract
- Azure Database for PostgreSQL Flexible Server
- Azure Container Apps environment and app definitions
- Docker-only local tooling for `terraform fmt`, `terraform validate`, `tflint`,
  `pre-commit`, and `detect-secrets`

## What this repository does not own

- Building and deploying the runtime images for backend/frontend
- The unified application release pipeline
- The MkDocs site in the parent `movie-finder` docs submodule, unless an infra
  contract actually changes and requires downstream documentation updates

---

## Local workflow

Contributor workflow in this repo is **strictly Docker-only**: all validation
commands execute through the provided `Makefile`.

### Prerequisites

- Docker 24+ with the Compose plugin
- GNU Make

### Setup

```bash
make init
make editor-up
```

`make init` builds the local tooling image and installs a git pre-commit hook
that delegates to `make pre-commit`.

`make editor-up` starts the long-lived `infra` container used for VS Code attach
and repeated `docker compose exec` flows.

### Common commands

```bash
make fmt           # terraform fmt -recursive
make validate      # terraform init -backend=false + terraform validate
make tflint        # tflint --init + tflint --format compact
make pre-commit    # full local hook suite
make check         # fmt-check + validate + tflint
make shell         # bash shell in the tooling container
make editor-down   # stop the local tooling container
```

### VS Code

The committed `.vscode/` config assumes this flow:

1. Run `make editor-up` from this repo root.
2. Use `Dev Containers: Attach to Running Container...`.
3. Attach to the `infra` service container started from this repo.
4. Use the committed tasks for `make ...` targets.

Use the `make ...` targets for Dockerized tooling. They export the absolute Git
metadata path so both standalone clones and parent-submodule checkouts work. If
you run `docker compose ...` directly from the parent submodule checkout, set
`INFRASTRUCTURE_GIT_DIR` to `$(git rev-parse --git-dir)` first.

---

## Secrets architecture

Production and staging secrets live in **Azure Key Vault** and are injected into
runtime services through managed identity. They are never committed to source,
written into Terraform variable files in git, or baked into Docker images.

CI-time credentials live in **Jenkins credentials** and remain separate from the
runtime Key Vault model.

The authoritative naming contract for providers, vector stores, and runtime
secrets is documented in
[`docs/provider-runtime-contract.md`](docs/provider-runtime-contract.md).

---

## Terraform layout

```text
infrastructure/
├── Dockerfile
├── docker-compose.yml
├── Makefile
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── environments/
│   │   ├── staging.tfvars
│   │   └── production.tfvars
│   ├── modules/
│   │   ├── container_apps/
│   │   ├── container_registry/
│   │   ├── database/
│   │   ├── key_vault/
│   │   └── networking/
│   └── scripts/
│       └── bootstrap-state.sh
└── docs/
    └── provider-runtime-contract.md
```

---

## Delivery model

- This repo defines the desired Azure infrastructure state.
- The parent `movie-finder` repo owns the unified Jenkins pipeline that deploys
  backend and frontend together.
- Until Terraform fully replaces the remaining operator runbook steps, the
  parent docs repo remains the place for procedural setup guidance.
