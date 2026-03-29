# AI Context — movie-finder-infrastructure

Shared reference for AI agents working in this repo standalone.

## Available slash commands (Claude Code)

Open `infrastructure/` as your workspace, then type `/`:

| Command | Usage |
|---|---|
| `/implement [issue-number]` | Implement an infrastructure issue |
| `/review-pr [pr-number]` | Review a PR in this repo |

## Prompts (Codex CLI / Gemini CLI / Ollama)

- `ai-context/prompts/implement.md` — implementation workflow for this repo
- `ai-context/prompts/review-pr.md` — review workflow

Usage:
```bash
cat ai-context/prompts/implement.md
gh pr diff N --repo aharbii/movie-finder-infrastructure > /tmp/pr.txt
cat /tmp/pr.txt | codex "$(cat ai-context/prompts/review-pr.md)"
```

## Important infrastructure rules

- No secrets, credentials, or API keys in any file
- Use Azure managed identity + Key Vault for all secrets
- New Azure resources must have cost implications noted
- New secrets must be manually added to Azure Key Vault AND Jenkins credentials store
- See `docs/qdrant-secret-model.md` for Qdrant access tier model and secret naming

## Issue hierarchy

Parent repo: `aharbii/movie-finder`.
Issues in this repo are child issues of `movie-finder`.

## Agent Briefing

Every issue must have an `## Agent Briefing` section before implementation.
Template: `ai-context/issue-agent-briefing-template.md`
