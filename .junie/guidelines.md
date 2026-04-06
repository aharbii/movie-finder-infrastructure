# JetBrains AI (Junie) — infrastructure submodule guidelines

This is **`movie-finder-infrastructure`** (`infrastructure/`) — IaC / Azure provisioning.
GitHub repo: `aharbii/movie-finder-infrastructure` · Parent: `aharbii/movie-finder`

---

## What this submodule does

Terraform IaC for all Azure infrastructure resources used by Movie Finder.

- **Provider:** `azurerm ~> 4.0`
- **State:** Azure Storage backend (remote state, state locking)
- **Environments:** dev / staging / prod via workspace or `.tfvars`
- **Secret lifecycle:** `ignore_changes` on Key Vault secret values (rotated externally)
- **Image lifecycle:** `ignore_changes` on container image tags (updated by CI/CD)

### Module layout

```
terraform/
├── main.tf              Root module
├── variables.tf         Input variables
├── outputs.tf           Output values
├── providers.tf         Provider configuration (azurerm, random)
├── backend.tf           Remote state configuration
└── modules/
    ├── networking/      VNet, subnets, NSGs
    ├── compute/         Azure Container Apps environment + apps
    ├── database/        Azure Database for PostgreSQL Flexible Server
    ├── storage/         Azure Storage (state bucket, data)
    └── keyvault/        Azure Key Vault + access policies
```

---

## Terraform standards

- `terraform fmt` must pass (enforced by pre-commit)
- `terraform validate` must pass before any plan/apply
- `tflint` must pass
- `terraform plan` before any `apply` — never `apply` without reviewing the plan
- Remote state always — never local `terraform.tfstate` in repo
- Tag all resources: `environment`, `project = "movie-finder"`, `managed_by = "terraform"`
- No hardcoded secrets — use Key Vault references or variable files not committed to git
- `ignore_changes` on `image` (container tags) and Key Vault secret values

---

## Workflow

- Branches: `feature/<kebab>`, `fix/<kebab>`, `chore/<kebab>`
- Commits: `feat(infra): add Azure Container Apps environment`
- Always run `terraform plan` and share output in PR for review
- After merge: bump pointer in root `movie-finder`

---

## Environment variables / secrets

All production secrets live in Azure Key Vault. Never commit secrets.
New secrets must be:
1. Added to Key Vault module in Terraform
2. Referenced via managed identity in container app config
3. Added to `backend/.env.example` or `frontend/.env.example` for local dev
4. Documented in `ONBOARDING.md` and `CONTRIBUTING.md`

---

## Submodule pointer bump

```bash
# in root movie-finder
git add infrastructure && git commit -m "chore(infra): bump to latest main"
```
