# Review PR — movie-finder-infrastructure

**Repo:** `aharbii/movie-finder-infrastructure`

Post findings as a comment only. Do not submit a GitHub review status.
The human decides whether to merge.

---

## Step 1 — Read PR, issue, and diff

```bash
gh pr view $ARGUMENTS --repo aharbii/movie-finder-infrastructure
gh issue view [LINKED_ISSUE] --repo aharbii/movie-finder-infrastructure
gh pr diff $ARGUMENTS --repo aharbii/movie-finder-infrastructure
```

Also check recent infrastructure changes for context:
```bash
git log --oneline -10
```

---

## Blocking findings

**Infrastructure-specific:**
- Secrets, API keys, or credentials in any file (hardcoded)
- Connection strings with embedded credentials (must use managed identity + Key Vault)
- Resource names that conflict with environment isolation (prod/staging/dev must be separate)
- New Azure resources with no cost impact noted in PR body
- `docs/devops-setup.md` not updated when new credentials or secrets are introduced
- New secrets not flagged for manual Key Vault + Jenkins setup in PR body

**PR hygiene:** AI disclosure missing, issue not linked, new secrets not explicitly listed.

---

## Post as a comment

```bash
gh pr comment $ARGUMENTS --repo aharbii/movie-finder-infrastructure \
  --body "[review comment body]"
```

```
## Review — [date]
Reviewed by: [tool and model]

### Verdict
PASS — no blocking findings. Human call to merge.
— or —
BLOCKING FINDINGS — must fix before merge.

### Blocking findings
[file:line] — [issue and fix]

### New secrets requiring manual setup
[list, or 'none']

### Non-blocking observations
[observation]

### Cross-cutting gaps
[any item not handled and not noted in PR body]
```
