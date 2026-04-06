# Session Start — movie-finder-infrastructure

Run these checks in parallel, then give a prioritised summary. Do not read any source files.

```bash
gh issue list --repo aharbii/movie-finder-infrastructure --state open --limit 20 \
  --json number,title,labels,assignees
```

```bash
gh pr list --repo aharbii/movie-finder-infrastructure --state open \
  --json number,title,state,labels,headRefName
```

```bash
gh issue list --repo aharbii/movie-finder --state open --limit 10 \
  --json number,title,labels
```

```bash
git status && git log --oneline -5
```

```bash
ls terraform/ 2>/dev/null && echo "Terraform scaffold present"
```

Then summarise:

- **Open issues in this repo** — number, title, severity label
- **Open PRs** — which are ready to review, which are blocked
- **Parent issues** — any root movie-finder issues that affect infrastructure
- **Current branch and uncommitted changes**
- **Terraform state** — which modules exist, which environments have tfvars
- **Recommended next action** — one specific thing

Note: new Azure resources require updating Key Vault secrets, Jenkins credentials,
and the per-repo `.env.example` files. Flag these before starting implementation.

Keep the summary under 25 lines. Do not propose solutions yet.
