#!/usr/bin/env bash
# =============================================================================
# bootstrap-state.sh — Create Azure Storage Account for Terraform remote state.
#
# Run this ONCE before the first 'terraform init'. It creates:
#   - Resource group:   movie-finder-tfstate
#   - Storage account:  moviefindertfstate  (must be globally unique)
#   - Container:        tfstate
#
# Usage:
#   az login
#   bash scripts/bootstrap-state.sh
# =============================================================================
set -euo pipefail

RESOURCE_GROUP="movie-finder-tfstate"
STORAGE_ACCOUNT="moviefindertfstate"
CONTAINER="tfstate"
LOCATION="eastus"

echo ">>> Creating resource group: ${RESOURCE_GROUP}"
az group create \
  --name     "${RESOURCE_GROUP}" \
  --location "${LOCATION}"

echo ">>> Creating storage account: ${STORAGE_ACCOUNT}"
az storage account create \
  --name                   "${STORAGE_ACCOUNT}" \
  --resource-group         "${RESOURCE_GROUP}" \
  --location               "${LOCATION}" \
  --sku                    Standard_LRS \
  --kind                   StorageV2 \
  --https-only             true \
  --min-tls-version        TLS1_2 \
  --allow-blob-public-access false

echo ">>> Creating blob container: ${CONTAINER}"
az storage container create \
  --name                "${CONTAINER}" \
  --account-name        "${STORAGE_ACCOUNT}" \
  --auth-mode           login

echo ">>> Done. Update terraform/providers.tf with storage_account_name=${STORAGE_ACCOUNT} if you changed it."
