# =============================================================================
# movie-finder-infrastructure — local Terraform tooling image
#
# Purpose:
#   - Terraform fmt / init / validate
#   - TFLint
#   - pre-commit + detect-secrets
#
# This image is for local development and editor/VS Code parity only.
# Application deployment remains owned by the parent movie-finder repository.
# =============================================================================

FROM hashicorp/terraform:1.9 AS terraform-bin

FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        make \
        unzip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=terraform-bin /bin/terraform /usr/local/bin/terraform

RUN curl -sSfL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

RUN python3 -m pip install --no-cache-dir \
    detect-secrets==1.5.0 \
    pre-commit==4.3.0

WORKDIR /workspace
ENTRYPOINT []
CMD ["sleep", "infinity"]
