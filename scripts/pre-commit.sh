#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/check-tools.sh
export PATH="$PWD/scripts/tools:$PATH"
if [[ "$(pre-commit --version)" != "pre-commit $PRE_COMMIT_VERSION" ]]; then
    echo "Install pre-commit==$PRE_COMMIT_VERSION before running checks." >&2
    exit 1
fi
exec pre-commit "$@"
