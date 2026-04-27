# =============================================================================
# Movie Finder Infrastructure — Docker-only developer contract
#
# Usage:
#   make help
#   make <target>
#
# All contributor commands execute through Docker Compose so Terraform, TFLint,
# pre-commit, and detect-secrets do not depend on host-managed tooling.
#
# Typical first-time flow:
#   make init        # build tooling image + install git hook
#   make editor-up   # start long-running infra container for VS Code attach
#   make check       # terraform fmt-check + validate + tflint
#
# When the tooling container is already running, commands use `docker compose
# exec` instead of starting a new container — faster for iterative work.
# =============================================================================

.PHONY: help init build setup clean clean-docker \
	editor-up editor-down ci-down shell logs up down run run-dev \
	fmt fmt-check validate tflint detect-secrets pre-commit check

.DEFAULT_GOAL := help

COMPOSE ?= docker compose
SERVICE ?= infra
GIT_DIR_HOST := $(abspath $(shell git rev-parse --git-dir))
GIT_HOOKS_DIR := $(GIT_DIR_HOST)/hooks

# Export so docker compose picks it up automatically (avoids per-command prefix).
export INFRASTRUCTURE_GIT_DIR := $(GIT_DIR_HOST)

# ---------------------------------------------------------------------------
# exec when running, run --rm otherwise — avoids container startup overhead
# for interactive development while remaining correct for CI.
# ---------------------------------------------------------------------------
define exec_or_run
	@if $(COMPOSE) ps --services --status running 2>/dev/null | grep -qx "$(SERVICE)"; then \
		$(COMPOSE) exec $(SERVICE) $(1); \
	else \
		$(COMPOSE) run --rm --no-deps $(SERVICE) $(1); \
	fi
endef

define exec_in_terraform
	$(call exec_or_run,bash -lc 'cd /workspace/terraform && $(1)')
endef

help:
	@echo ""
	@echo "Movie Finder Infrastructure — available targets"
	@echo "==============================================="
	@echo ""
	@echo "  Setup"
	@echo "    init           Build tooling image and install git hook"
	@echo ""
	@echo "  Editor"
	@echo "    editor-up      Start the attached-container workspace in the background"
	@echo "    editor-down    Stop the local workspace container"
	@echo "    shell          Open a bash shell in the workspace container"
	@echo ""
	@echo "  Lifecycle"
	@echo "    up             Alias for editor-up"
	@echo "    down           Alias for editor-down"
	@echo "    logs           Follow workspace container logs"
	@echo "    ci-down        Full cleanup for CI: stop containers and remove volumes + local image"
	@echo ""
	@echo "  Terraform quality"
	@echo "    fmt            Run terraform fmt -recursive"
	@echo "    fmt-check      Run terraform fmt -check -recursive"
	@echo "    validate       Run terraform init -backend=false + terraform validate"
	@echo "    tflint         Run tflint --init + tflint --format compact"
	@echo "    detect-secrets Run detect-secrets scan"
	@echo "    pre-commit     Run all pre-commit hooks"
	@echo "    check          fmt-check + validate + tflint"
	@echo ""
	@echo "  Maintenance"
	@echo "    clean          Remove Terraform working directories and local caches"
	@echo "    clean-docker   Stop containers and remove volumes + local image"
	@echo ""
	@echo "  Compatibility aliases"
	@echo "    build          Alias for init"
	@echo "    run / run-dev  Alias for editor-up"
	@echo "    setup          Alias for init"
	@echo ""

init:
	$(COMPOSE) build $(SERVICE)
	@printf '#!/bin/sh\nexec make pre-commit\n' > $(GIT_HOOKS_DIR)/pre-commit
	@chmod +x $(GIT_HOOKS_DIR)/pre-commit
	@echo ">>> git pre-commit hook installed (calls 'make pre-commit' on every commit)"

build: init
setup: init

editor-up:
	$(COMPOSE) up -d $(SERVICE)

up: editor-up
run: editor-up
run-dev: editor-up

editor-down:
	$(COMPOSE) down --remove-orphans

down: editor-down

ci-down:
	$(COMPOSE) down -v --rmi local --remove-orphans

logs:
	$(COMPOSE) logs -f $(SERVICE)

shell:
	@if $(COMPOSE) ps --services --status running 2>/dev/null | grep -qx "$(SERVICE)"; then \
		$(COMPOSE) exec $(SERVICE) bash; \
	else \
		$(COMPOSE) run --rm $(SERVICE) bash; \
	fi

fmt:
	$(call exec_in_terraform,terraform fmt -recursive)

fmt-check:
	$(call exec_in_terraform,terraform fmt -check -recursive)

validate:
	$(call exec_in_terraform,terraform init -backend=false -reconfigure >/dev/null && terraform validate)

tflint:
	$(call exec_in_terraform,tflint --init >/dev/null && tflint --format compact)

detect-secrets:
	$(call exec_or_run,detect-secrets scan --baseline .secrets.baseline)

pre-commit:
	$(call exec_or_run,pre-commit run --all-files)

check: fmt-check validate tflint

clean:
	@echo ">>> Removing Terraform working directories and local caches (via Docker)..."
	$(call exec_or_run,bash -lc 'rm -rf /workspace/terraform/.terraform /workspace/terraform/.terraform.tfstate.lock.info /workspace/.pre-commit-cache')
	@echo "Clean complete."

clean-docker: ci-down
