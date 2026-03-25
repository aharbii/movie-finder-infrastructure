# Gemini CLI — infrastructure submodule

Foundational mandate for `movie-finder-infrastructure` (`infrastructure/`).

---

## What this submodule does
IaC (Terraform/Bicep) for Azure provisioning (ACR, Key Vault, Container Apps).

---

## Secrets policy
- **No secrets in code.** `detect-secrets` hook enforced.
- **Azure Key Vault** for runtime secrets.
- **Jenkins credentials** for CI secrets.
- Update `.env.example` in all affected repos when adding secrets.

---

## Checklist for infra changes
- Idempotent IaC files.
- Update `docs/devops-setup.md` credentials table.
- Flag new secrets to user for manual addition to Key Vault/Jenkins.

---

## VSCode setup

`infrastructure/.vscode/` — workspace configuration for IaC editing.
- `settings.json`: Terraform/Bicep formatter placeholders (uncomment once issue #22 tooling is chosen)
- `extensions.json`: `hashicorp.terraform`, `ms-azuretools.vscode-bicep`, `ms-azuretools.azure-resources`, Docker, YAML
- Modifying configs: uncomment the relevant formatter block once IaC tooling is decided.
  Update `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, and the repo's `.github/copilot-instructions.md` after.
