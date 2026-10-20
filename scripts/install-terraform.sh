#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

destination=${1:?Usage: bash scripts/install-terraform.sh INSTALL_DIRECTORY}
version=$(head -n 1 .terraform-version)
case "$(uname -s)" in
    Linux) os=linux ;;
    Darwin) os=darwin ;;
    *) echo "Unsupported Terraform installation OS: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    arm64|aarch64) arch=arm64 ;;
    *) echo "Unsupported Terraform installation architecture: $(uname -m)" >&2; exit 1 ;;
esac

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
archive="terraform_${version}_${os}_${arch}.zip"
base_url="https://releases.hashicorp.com/terraform/$version"
curl -fsSL "$base_url/$archive" -o "$work/$archive"
curl -fsSL "$base_url/terraform_${version}_SHA256SUMS" -o "$work/SHA256SUMS"
(
    cd "$work"
    awk -v archive="$archive" '$2 == archive' SHA256SUMS > checksum
    if [[ ! -s checksum ]]; then
        echo "No published checksum for $archive." >&2
        exit 1
    fi
    shasum -a 256 -c checksum
    unzip -q "$archive" terraform
)
mkdir -p "$destination"
install -m 0755 "$work/terraform" "$destination/terraform"
"$destination/terraform" version
