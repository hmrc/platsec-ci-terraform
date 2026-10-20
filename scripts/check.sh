#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
source scripts/check-tools.sh
check=$1
shift
for tool in docker jq; do
    if ! command -v "$tool" >/dev/null; then
        echo "Required check dependency is missing: $tool" >&2
        exit 1
    fi
done
docker info >/dev/null

case "$check" in
    markdown)
        exec docker run --rm --network none --volume "$PWD:/lint/input:ro" \
            "$MARKDOWN_IMAGE" --frail "$@"
        ;;
    shellcheck)
        exec docker run --rm --network none --volume "$PWD:/src:ro" \
            --workdir /src "$SHELLCHECK_IMAGE" --external-sources "$@"
        ;;
    trufflehog) ;;
    *) echo "Unknown check: $check" >&2; exit 2 ;;
esac

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/source" "$work/reports"
git ls-files --cached -z > "$work/files"
while IFS= read -r -d '' file; do
    case "/$file" in
        */.terraform/*|*/.terraform.d/*|*/.external_modules/*|*.tfstate|*.tfstate.*|*.tfplan) continue ;;
    esac
    if [[ -L "$file" ]]; then
        echo "Checks do not support tracked symlinks: $file" >&2
        exit 1
    fi
    [[ -f "$file" ]] || continue
    mkdir -p "$work/source/$(dirname "$file")"
    cp "$file" "$work/source/$file"
done < "$work/files"

status=0
docker run --rm --network none --volume "$work/source:/src:ro" \
    "$TRUFFLEHOG_IMAGE" filesystem /src --no-update --no-verification \
    --results=verified,unknown,unverified,filtered_unverified \
    --fail --fail-on-scan-errors --json --log-level=-1 \
    > "$work/reports/secrets.json" || status=$?
jq -r '"Secret candidate: \(.DetectorName) in \(.SourceMetadata.Data.Filesystem.file)"' \
    "$work/reports/secrets.json"
if [[ "$status" != 0 ]]; then
    echo "Secret scan failed (exit $status). Remove candidates; values are intentionally redacted." >&2
fi
exit "$status"
