# Qdrant Secret Model and CI Secret Naming Convention

**Status:** Accepted
**Workstream:** Docker-only local dev standardization ([movie-finder#35](https://github.com/aharbii/movie-finder/issues/35))
**Infrastructure issue:** [movie-finder-infrastructure#8](https://github.com/aharbii/movie-finder-infrastructure/issues/8)

This document is the authoritative reference for how Qdrant credentials and other
cross-repo secrets are named, scoped, and injected across the Movie Finder project.
All repos in workstream #35 must use the names defined here.

---

## 1. Qdrant access tier model

Qdrant Cloud is the vector store for Movie Finder. It is **always external** — no local
Qdrant container is used in any environment (development, CI, staging, or production).
See [infrastructure#2](https://github.com/aharbii/movie-finder-infrastructure/issues/2) for
the longer-term plan to provision per-environment Qdrant collections.

Two access tiers are defined. The principle of least privilege drives this split: services
that only query the vector store must never hold a key that can write to it.

### Tier definitions

| Tier                   | Who uses it                          | Capability                                           |
| ---------------------- | ------------------------------------ | ---------------------------------------------------- |
| **Read-only (RO)**     | `backend/app/`, `backend/chain/`     | Query (search, retrieve) only — no upsert, no delete |
| **Write-capable (RW)** | `backend/rag_ingestion/` exclusively | Upsert and delete — full collection management       |

### Environment variable names

| Variable                 | Tier    | Description                                              |
| ------------------------ | ------- | -------------------------------------------------------- |
| `QDRANT_URL`             | Both    | Qdrant Cloud cluster URL (same endpoint for both tiers)  |
| `QDRANT_API_KEY_RO`      | RO only | Read-only API key — injected into app and chain          |
| `QDRANT_API_KEY_RW`      | RW only | Write-capable API key — injected into rag_ingestion only |
| `QDRANT_COLLECTION_NAME` | Both    | Target collection name (may vary per environment)        |

> **Migration note:** The legacy `QDRANT_API_KEY` variable (single key, no suffix) is
> superseded by `QDRANT_API_KEY_RO` and `QDRANT_API_KEY_RW`. Any repo still referencing
> `QDRANT_API_KEY` should migrate as part of implementing workstream #35.

### Per-repo consumption table

| Repo                                          | Variable used                                               | Tier                                          |
| --------------------------------------------- | ----------------------------------------------------------- | --------------------------------------------- |
| `aharbii/movie-finder-backend` (`app/`)       | `QDRANT_URL`, `QDRANT_API_KEY_RO`, `QDRANT_COLLECTION_NAME` | RO                                            |
| `aharbii/movie-finder-chain`                  | `QDRANT_URL`, `QDRANT_API_KEY_RO`, `QDRANT_COLLECTION_NAME` | RO (dev/CI only — library consumed by `app/`) |
| `aharbii/movie-finder-rag` (`rag_ingestion/`) | `QDRANT_URL`, `QDRANT_API_KEY_RW`, `QDRANT_COLLECTION_NAME` | RW                                            |

---

## 2. Secrets storage locations

### Azure Key Vault (runtime — production and staging)

The deployed Azure Container Apps are `backend-app` (FastAPI) and `frontend-app` (nginx).
`backend/chain/` is a library bundled into `backend-app` and is not a separate Container App.
`backend/rag_ingestion/` is an **offline CI pipeline** — it runs as a Jenkins job and is
never deployed as an Azure Container App.

This document covers secrets for `backend-app` only. The `frontend-app` Container App
serves a pre-built Angular bundle and requires no AI API keys.

Secrets are read from Azure Key Vault via managed identity. No secret is passed through
environment variables baked into Docker images or injected through Jenkins build logs.
`rag_ingestion` secrets live in the Jenkins credentials store only, not in Azure Key Vault.

| Secret                       | Azure Key Vault secret name | Container App |
| ---------------------------- | --------------------------- | ------------- |
| Qdrant cluster URL           | `qdrant-url`                | backend-app   |
| Qdrant read-only API key     | `qdrant-api-key-ro`         | backend-app   |
| Qdrant collection name       | `qdrant-collection-name`    | backend-app   |
| OpenAI API key               | `openai-api-key`            | backend-app   |
| Anthropic API key            | `anthropic-api-key`         | backend-app   |
| JWT signing key              | `app-secret-key`            | backend-app   |
| PostgreSQL URL               | `postgres-url`              | backend-app   |
| LangSmith API key _(opt-in)_ | `langsmith-api-key`         | backend-app   |

> **Manual step required:** All secrets above must be added to Azure Key Vault by the
> operator. Claude cannot do this. See `CLAUDE.md §Secrets and credentials architecture`
> for the full Key Vault rotation workflow.

### Jenkins credentials store (CI builds)

Jenkins credential IDs used during CONTRIBUTION and INTEGRATION pipeline runs. These must
be added manually via the Jenkins UI.

| Jenkins credential ID    | Maps to env var          | Used by                      |
| ------------------------ | ------------------------ | ---------------------------- |
| `qdrant-url`             | `QDRANT_URL`             | backend-app, chain pipelines |
| `qdrant-api-key-ro`      | `QDRANT_API_KEY_RO`      | backend-app, chain pipelines |
| `qdrant-collection-name` | `QDRANT_COLLECTION_NAME` | backend-app, chain pipelines |

> **Secrets not needed in current CI:**
>
> - `APP_SECRET_KEY` and `DATABASE_URL` — the app test suite hard-codes a test JWT secret
>   and connects to a local Postgres sidecar (`postgres:postgres`). Neither production
>   secret is needed in CI.
> - `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `KAGGLE_API_TOKEN`, `qdrant-api-key-rw` — Jenkins
>   currently runs tests with stubs only; no real LLM calls or dataset downloads are made.
>   The RAG ingestion CI job is future work tracked in
>   [rag#6](https://github.com/aharbii/movie-finder-rag/issues/6). These credentials will
>   be added to the Jenkins store when that job lands.

> **Note on CI system dependency:** If the project migrates from Jenkins to GitHub Actions
> (tracked in [infrastructure#4](https://github.com/aharbii/movie-finder-infrastructure/issues/4)),
> the credential IDs above become GitHub Actions secret names. The env var names remain
> identical — only the injection mechanism changes. Repos implementing Makefile or CI
> targets must be written to accept the env vars by name, not by Jenkins-specific
> credential binding syntax.

---

## 3. Full cross-repo secret contract

This table is the reference for `.env.example` files across all repos. Every repo must
declare all variables it consumes, even if the value is injected at runtime.

`backend/chain/` is a library; its env vars are needed for local dev only — its test
suite fully mocks all external dependencies (Qdrant, OpenAI, Anthropic) and does not
make real API calls. At runtime, env vars are inherited from the hosting `app/` process.

| Variable                 | backend/app |  backend/chain  | backend/rag_ingestion | frontend |
| ------------------------ | :---------: | :-------------: | :-------------------: | :------: |
| `QDRANT_URL`             |      ✓      |     ✓ (dev)     |           ✓           |    —     |
| `QDRANT_API_KEY_RO`      |      ✓      |     ✓ (dev)     |           —           |    —     |
| `QDRANT_API_KEY_RW`      |      —      |        —        |           ✓           |    —     |
| `QDRANT_COLLECTION_NAME` |      ✓      |     ✓ (dev)     |           ✓           |    —     |
| `OPENAI_API_KEY`         |      —      |     ✓ (dev)     |           ✓           |    —     |
| `ANTHROPIC_API_KEY`      |      —      |     ✓ (dev)     |           —           |    —     |
| `APP_SECRET_KEY`         |      ✓      |        —        |           —           |    —     |
| `DATABASE_URL`           |      ✓      |        —        |           —           |    —     |
| `KAGGLE_API_TOKEN`       |      —      |        —        |           ✓           |    —     |
| `LANGSMITH_API_KEY`      | ✓ (opt-in)  | ✓ (opt-in, dev) |           —           |    —     |
| `LANGSMITH_TRACING`      | ✓ (opt-in)  | ✓ (opt-in, dev) |           —           |    —     |
| `LANGSMITH_ENDPOINT`     | ✓ (opt-in)  | ✓ (opt-in, dev) |           —           |    —     |
| `LANGSMITH_PROJECT`      | ✓ (opt-in)  | ✓ (opt-in, dev) |           —           |    —     |

Backend runtime also uses non-secret app settings that are not stored in Key Vault:
`CORS_ORIGINS`, `GLOBAL_RATE_LIMIT`, `AUTH_RATE_LIMIT`, `CHAT_RATE_LIMIT`, and
`MAX_MESSAGE_LENGTH`. Treat these as deployment-time configuration, not secrets.

---

## 4. Dependency notes

### infrastructure#2 — Shared production Qdrant cluster across all environments

The RO/RW key split defined in this document is complementary to, but independent of,
provisioning per-environment Qdrant collections (tracked in
[infrastructure#2](https://github.com/aharbii/movie-finder-infrastructure/issues/2)).
The split should be implemented now regardless of whether environment isolation is in place.
When per-environment collections land, `QDRANT_COLLECTION_NAME` will differ by environment;
the key names remain unchanged.

### infrastructure#3 — Jenkins CI relies on free ngrok tunnel for GitHub webhooks

The Jenkins credential IDs defined in §2 assume the current Jenkins + ngrok CI setup. If
the ngrok tunnel is replaced (see
[infrastructure#3](https://github.com/aharbii/movie-finder-infrastructure/issues/3))
without migrating to GitHub Actions, the credential IDs are unaffected — the webhook
mechanism and the credentials store are independent concerns.

### infrastructure#4 — Migrate CI from Jenkins to GitHub Actions

If GitHub Actions is adopted (see
[infrastructure#4](https://github.com/aharbii/movie-finder-infrastructure/issues/4))
**before** the sibling repos (backend#14, chain#9, imdbapi#3, rag#13, frontend#5) finish
their Makefile/CI target implementations, there will be a window where some repos use
Jenkins credential binding syntax and others use GitHub Actions `${{ secrets.* }}` syntax.
The mitigation is:

1. Keep the env var names identical across both CI systems (this document enforces that).
2. CI scripts must reference env vars by name only — never by Jenkins-specific binding.
3. Any repo implementing its CI targets before the GH Actions migration lands should use
   `withCredentials` blocks that bind to the env var names in this table.
4. The migration issue (infrastructure#4) must list all repos that need Jenkinsfile →
   workflow conversion as sub-tasks to avoid partial-migration drift.
