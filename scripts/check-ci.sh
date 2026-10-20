#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

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
