# Implement Issue — movie-finder-infrastructure

**Repo:** `aharbii/movie-finder-infrastructure`
**Parent tracker:** `aharbii/movie-finder`
**Status:** IaC not yet implemented (issue #22). Read current repo state before assuming what exists.

Implement GitHub issue #$ARGUMENTS from `aharbii/movie-finder-infrastructure`.

---

## Step 1 — Read the child issue

```bash
gh issue view $ARGUMENTS --repo aharbii/movie-finder-infrastructure
```

Find the **Agent Briefing** section. If absent, ask the user to add it before proceeding.

---

## Step 2 — Read the parent issue for full context

```bash
gh issue view [PARENT_NUMBER] --repo aharbii/movie-finder
```

---

## Step 3 — Check current repo state first

```bash
ls -la
```

This repo may have minimal content. Read what exists before implementing.

---

## Step 4 — Create the branch

```bash
git checkout main && git pull
git checkout -b [type]/[kebab-case-title]
```

---

## Step 5 — Implement

Infrastructure context:
- Target: Azure Container Apps + Azure Container Registry
- CI/CD: Jenkins Multibranch Pipelines → ACR
- Secrets: Azure Key Vault (managed identity) — never in code or Docker images
- No secrets through Jenkins build logs
- If writing Terraform/Bicep: follow the patterns established by the team
- Always update `docs/devops-setup.md` (in docs submodule) when adding new infra, credentials, or secrets

---

## Step 6 — Validate

```bash
# Terraform (if applicable):
terraform fmt -check
terraform validate

# Bicep (if applicable):
az bicep build --file [file]
```

---

## Step 7 — Commit

```bash
git add [only changed files — never git add -A]
git commit -m "$(cat <<'EOF'
type(scope): short summary

[why]

Closes #$ARGUMENTS
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

---

## Step 8 — Open PR

```bash
gh pr create \
  --repo aharbii/movie-finder-infrastructure \
  --title "type(scope): short summary" \
  --body "$(cat <<'EOF'
[PR body]

Closes #$ARGUMENTS
Parent: [PARENT_ISSUE_URL]

---
> AI-assisted implementation: Claude Code (claude-sonnet-4-6)
EOF
)"
```

---

## Step 9 — Cross-cutting comments

Comment on related issues (from Agent Briefing), the child issue, and the parent issue.
Flag any new secrets to user for manual addition to Azure Key Vault and Jenkins credentials store.
