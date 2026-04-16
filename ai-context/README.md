# AI Context — movie-finder-infrastructure

Shared reference for AI agents working in this repo standalone.

## Available slash commands (Claude Code)

Open `infrastructure/` as your workspace, then type `/`:

| Command                     | Usage                             |
| --------------------------- | --------------------------------- |
| `/implement [issue-number]` | Implement an infrastructure issue |
| `/review-pr [pr-number]`    | Review a PR in this repo          |

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
- Use Azure Key Vault for runtime secrets and Jenkins credentials for CI-only secrets
- Use the committed Docker-only workflow from this repo root
- Run `make check` for Terraform validation and `make pre-commit` before committing
- Deployment orchestration remains in the parent `movie-finder` repo
- Update the parent docs repo only when the infrastructure contract actually changes

## Issue hierarchy

Parent repo: `aharbii/movie-finder`.
Issues in this repo are child issues of `movie-finder`.

## Agent Briefing

Every issue must have an `## Agent Briefing` section before implementation.
Template: `ai-context/issue-agent-briefing-template.md`
