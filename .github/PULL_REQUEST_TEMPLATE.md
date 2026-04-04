## What and why

<!-- What changed and why? Link the issue this addresses. -->

Closes #

## Type of change

- [ ] New Azure resource or IaC module
- [ ] Secret naming convention change or Key Vault update
- [ ] Jenkins credential addition or rename
- [ ] Provisioning script update
- [ ] Documentation only (setup guide, secret model)

## How to test

1.
2.
3.

## Checklist

### Secrets and credentials

- [ ] New secrets added to Azure Key Vault manually (never in source code)
- [ ] New Jenkins credentials added to the Jenkins credentials store (if needed at CI time)
- [ ] `.env.example` updated in **every affected repo** with the new variable names
- [ ] `docs/qdrant-secret-model.md` updated if Qdrant or other secret names changed
- [ ] `docs/devops/setup.md` credentials table updated

### IaC _(if applicable)_

- [ ] No secrets, credentials, or internal URLs hard-coded in IaC files
- [ ] `terraform validate` / `az deployment validate` passes (or explicitly noted as untested)
- [ ] Idempotent: applying the same change twice produces no error

### Documentation

- [ ] `CHANGELOG.md` updated under `[Unreleased]`
- [ ] `README.md` updated if the repository structure or provisioning steps changed

### Review

- [ ] PR title follows `chore(infra): summary` or `docs(infra): summary` (≤72 chars, lowercase)
- [ ] PR description links the issue and discloses the AI authoring tool + model used
- [ ] Any AI-assisted review comment or approval discloses the review tool + model
