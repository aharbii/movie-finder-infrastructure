# Provider Runtime Contract

**Status:** Accepted  
**Architecture:** ADR-0008 provider runtime

This document is the canonical contract for provider selection, vector-store
selection, model names, collection naming, and secret names across Movie Finder.
All repos must use these names exactly.

---

## Runtime Shape

The backend container includes the chain package. The chain is not deployed as a
separate service. The RAG repo is an offline Jenkins pipeline that writes the
same vector target the backend reads.

| Runtime surface | Owner | Purpose |
| --- | --- | --- |
| `backend` Container App | parent `movie-finder` deploys, `infrastructure` provisions | FastAPI, LangGraph chain, PostgreSQL sessions/checkpoints |
| `rag` Jenkins job | `movie-finder-rag` | Offline ingestion into the configured vector store |
| `qdrant-explorer` MCP | `mcp/qdrant-explorer` | Developer inspection tool for Qdrant collections |

---

## Canonical Environment Variables

| Variable | Backend | Chain local dev | RAG | qdrant-explorer | Notes |
| --- | :---: | :---: | :---: | :---: | --- |
| `WITH_PROVIDERS` | build | build | — | — | Optional dependency bundle installed into the image |
| `CLASSIFIER_PROVIDER` | yes | yes | — | — | `anthropic`, `openai`, `groq`, `together`, `ollama`, or `google` |
| `CLASSIFIER_MODEL` | yes | yes | — | — | Lightweight classification/confirmation model |
| `REASONING_PROVIDER` | yes | yes | — | — | Reasoning and Q&A chat provider |
| `REASONING_MODEL` | yes | yes | — | — | Reasoning and Q&A model |
| `EMBEDDING_PROVIDER` | yes | yes | yes | — | Query and ingestion embedding provider |
| `EMBEDDING_MODEL` | yes | yes | yes | — | Must match between backend query and RAG ingestion |
| `EMBEDDING_DIMENSION` | yes | yes | yes | — | Must match the stored vector dimension |
| `VECTOR_STORE` | yes | yes | yes | — | `qdrant`, `chromadb`, `pinecone`, or `pgvector` |
| `VECTOR_COLLECTION_PREFIX` | yes | yes | yes | — | Prefix used to derive the final vector target |
| `VECTOR_STORE_TARGET_NAME` | — | — | generated | yes | Final target: `{prefix}_{sanitized_embedding_model}_{dimension}` |
| `QDRANT_URL` | if qdrant | if qdrant | if qdrant | yes | Qdrant cluster URL |
| `QDRANT_API_KEY_RO` | if qdrant | if qdrant | — | yes | Read-only key for query/runtime tools |
| `QDRANT_API_KEY_RW` | — | — | if qdrant | — | Write-capable key for ingestion |
| `CHROMADB_PERSIST_PATH` | if chromadb | if chromadb | if chromadb | — | Local Chroma persistence path |
| `PINECONE_API_KEY` | if pinecone | if pinecone | if pinecone | — | Pinecone API key |
| `PINECONE_INDEX_NAME` | if pinecone | if pinecone | if pinecone | — | Pinecone index name |
| `PINECONE_INDEX_HOST` | if pinecone | if pinecone | if pinecone | — | Pinecone index host when required |
| `PINECONE_CLOUD` | if pinecone | if pinecone | if pinecone | — | Pinecone serverless cloud |
| `PINECONE_REGION` | if pinecone | if pinecone | if pinecone | — | Pinecone serverless region |
| `PGVECTOR_DSN` | if pgvector | if pgvector | if pgvector | — | PostgreSQL DSN for pgvector |
| `PGVECTOR_SCHEMA` | if pgvector | if pgvector | if pgvector | — | PostgreSQL schema token |
| `ANTHROPIC_API_KEY` | if selected | if selected | — | — | Anthropic chat provider |
| `OPENAI_API_KEY` | if selected | if selected | if selected | — | OpenAI chat or embedding provider |
| `GROQ_API_KEY` | if selected | if selected | — | — | Groq chat provider |
| `TOGETHER_API_KEY` | if selected | if selected | — | — | Together chat provider |
| `GOOGLE_API_KEY` | if selected | if selected | if selected | — | Google chat or embedding provider |
| `OLLAMA_BASE_URL` | if selected | if selected | if selected | — | Docker-reachable Ollama endpoint |
| `APP_SECRET_KEY` | yes | — | — | — | Backend JWT signing key |
| `DATABASE_URL` | yes | — | — | — | Backend PostgreSQL sessions and LangGraph checkpoints |
| `KAGGLE_API_TOKEN` | — | — | yes | — | Dataset ingestion token |
| `LANGSMITH_API_KEY` | optional | optional | — | — | LangSmith tracing |
| `LANGSMITH_TRACING` | optional | optional | — | — | `true` or `false` |
| `LANGSMITH_ENDPOINT` | optional | optional | — | — | LangSmith API endpoint |
| `LANGSMITH_PROJECT` | optional | optional | — | — | LangSmith project name |

Backend runtime also uses non-secret application settings:
`CORS_ORIGINS`, `GLOBAL_RATE_LIMIT`, `AUTH_RATE_LIMIT`, `CHAT_RATE_LIMIT`,
`MAX_MESSAGE_LENGTH`, `LOG_LEVEL`, and `LOG_FORMAT`.

---

## Azure Key Vault

The backend Container App reads runtime secrets from Azure Key Vault through
managed identity. Terraform creates a Key Vault secret only when its
corresponding variable is non-empty, and the Container App only injects optional
provider env vars when those values are configured.

| Key Vault secret | Env var |
| --- | --- |
| `app-secret-key` | `APP_SECRET_KEY` |
| `postgres-url` | `DATABASE_URL` |
| `anthropic-api-key` | `ANTHROPIC_API_KEY` |
| `openai-api-key` | `OPENAI_API_KEY` |
| `groq-api-key` | `GROQ_API_KEY` |
| `together-api-key` | `TOGETHER_API_KEY` |
| `google-api-key` | `GOOGLE_API_KEY` |
| `qdrant-url` | `QDRANT_URL` |
| `qdrant-api-key-ro` | `QDRANT_API_KEY_RO` |
| `qdrant-api-key-rw` | `QDRANT_API_KEY_RW` |
| `pinecone-api-key` | `PINECONE_API_KEY` |
| `pgvector-dsn` | `PGVECTOR_DSN` |
| `langsmith-api-key` | `LANGSMITH_API_KEY` |

Terraform validates the backend Container App contract before deploy:

- Anthropic providers require `anthropic_api_key`.
- OpenAI providers require `openai_api_key`.
- Groq providers require `groq_api_key`.
- Together providers require `together_api_key`.
- Google providers require `google_api_key`.
- `VECTOR_STORE=qdrant` requires `qdrant_url` and `qdrant_api_key_ro`.
- `VECTOR_STORE=pinecone` requires `pinecone_api_key`.
- `VECTOR_STORE=pgvector` requires `pgvector_dsn`.

---

## Jenkins Credentials

Jenkins credential IDs match the Key Vault secret names where a secret exists.
Pipelines bind credentials to the canonical environment variable names above.

The parent `movie-finder` pipeline owns backend image builds and Azure deploys.
The RAG pipeline owns ingestion credentials and must use the same provider,
embedding, vector-store, and collection prefix values as the backend deploy.

---

## Collection Naming

The final vector target is computed from:

```text
{VECTOR_COLLECTION_PREFIX}_{sanitized(EMBEDDING_MODEL)}_{EMBEDDING_DIMENSION}
```

Example:

```text
movies_text_embedding_3_large_3072
```

The backend query path and the RAG ingestion path must resolve to the same final
target. Provider changes that alter the embedding model or dimension require a
new ingestion run before the backend can query that target.
