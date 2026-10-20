#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -n "${CODEBUILD_BUILD_ID:-}" ]]; then
    source scripts/check-tools.sh
    export PATH="/usr/local/bin:$PATH"
    if ! command -v pre-commit >/dev/null ||
        [[ "$(pre-commit --version)" != "pre-commit $PRE_COMMIT_VERSION" ]]; then
        echo "CodeBuild: installing pre-commit==$PRE_COMMIT_VERSION"
        pip3 install "pre-commit==$PRE_COMMIT_VERSION"
        hash -r
    fi
    if ! command -v terraform >/dev/null ||
        [[ "$(terraform version -json | jq -er '.terraform_version')" != "$(head -n 1 .terraform-version)" ]]; then
        echo "CodeBuild: installing Terraform $(head -n 1 .terraform-version)"
        bash scripts/install-terraform.sh /usr/local/bin
    fi
fi

if [[ -e .git ]]; then
    exec bash scripts/pre-commit.sh run "$@" --all-files
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
tar -cf - . | tar -xf - -C "$work"
cd "$work"
git init -q
git add --all --force
bash scripts/pre-commit.sh run "$@" --all-files
