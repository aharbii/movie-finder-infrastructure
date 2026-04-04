# Movie Finder — Infrastructure

IaC and Azure provisioning for the Movie Finder application.

> **Status:** Terraform/Bicep implementation is in progress (tracked as [issue #22](https://github.com/aharbii/movie-finder/issues/22)). The current state of this repository is documentation and manual provisioning scripts; automated IaC is not yet complete.

---

## What this repository covers

| Resource                                      | Technology          | Status  |
| --------------------------------------------- | ------------------- | ------- |
| Azure Container Apps (backend + frontend)     | Bicep / manual      | Planned |
| Azure Container Registry                      | Manual provisioning | Live    |
| Azure Key Vault (runtime secrets)             | Manual provisioning | Live    |
| Azure Database for PostgreSQL Flexible Server | Manual provisioning | Live    |
| Networking, RBAC, managed identity            | Bicep / manual      | Planned |

---

## Secrets architecture

Production secrets live in **Azure Key Vault** and are injected into Container Apps at
runtime via managed identity. They are never stored in environment files, Docker images,
or Jenkins build logs.

The authoritative secret naming convention and cross-repo environment variable contract
is documented in [`docs/qdrant-secret-model.md`](docs/qdrant-secret-model.md).

| Secret type                        | Location                                   |
| ---------------------------------- | ------------------------------------------ |
| Anthropic, OpenAI, Qdrant API keys | Azure Key Vault                            |
| Database password, JWT signing key | Azure Key Vault                            |
| CI-time credentials (tests)        | Jenkins credentials store                  |
| Docker registry login              | ACR managed identity (automatic)           |
| Key Vault access                   | Container App managed identity (automatic) |

---

## Initial provisioning

Until the IaC automation is complete, follow the step-by-step manual provisioning guide
in [`docs/devops/setup.md`](../docs/devops/setup.md) (in the `docs/` submodule).

That guide covers:

- Azure resource group and Container Registry setup
- Azure Database for PostgreSQL Flexible Server
- Azure Key Vault with managed identity bindings
- Azure Container Apps deployment
- Jenkins setup and credential configuration

---

## Repository structure

```
infrastructure/
├── docs/
│   └── qdrant-secret-model.md   Cross-repo secret naming convention (authoritative)
└── CHANGELOG.md
```
