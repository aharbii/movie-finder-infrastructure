# Changelog

All notable changes to `movie-finder-infrastructure` are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- `docs/qdrant-secret-model.md` — authoritative reference for the Qdrant RO/RW access
  tier model, Azure Key Vault secret names, Jenkins credential IDs, and the full
  cross-repo environment variable contract for workstream #35
  ([infrastructure#8](https://github.com/aharbii/movie-finder-infrastructure/issues/8),
  [movie-finder#35](https://github.com/aharbii/movie-finder/issues/35))

### Changed
- `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `.github/copilot-instructions.md` — updated
  Jenkins credential IDs to reflect the new `qdrant-api-key-ro` / `qdrant-api-key-rw`
  split; clarified that `rag_ingestion` is an offline CI pipeline, not an Azure
  Container App
