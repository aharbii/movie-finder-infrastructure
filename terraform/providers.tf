terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    # -------------------------------------------------------------------------
    # AWS and GCP providers are declared here but remain disabled by default.
    # To activate a provider, set its enabled variable to true and supply the
    # required authentication variables in the relevant .tfvars file.
    # -------------------------------------------------------------------------
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Remote state — update the storage_account_name and container_name to match
  # the Azure Storage Account created by scripts/bootstrap-state.sh.
  backend "azurerm" {
    resource_group_name  = "movie-finder-tfstate"
    storage_account_name = "moviefindertfstate"
    container_name       = "tfstate"
    key                  = "movie-finder.tfstate"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Azure
# ─────────────────────────────────────────────────────────────────────────────
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.azure_subscription_id
}

# ─────────────────────────────────────────────────────────────────────────────
# AWS — disabled by default; activate by setting var.enable_aws = true
# ─────────────────────────────────────────────────────────────────────────────
provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────────────────────────────────────
# GCP — disabled by default; activate by setting var.enable_gcp = true
# ─────────────────────────────────────────────────────────────────────────────
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
