#!/usr/bin/env bash
set -euo pipefail

env_id="${1:-ENV-1}"
os_name="$(uname -s)"
fish_version=""
if command -v fish >/dev/null 2>&1; then
  fish_version="$(fish --version | awk '{print $3}')"
fi
repo_root="$(cd "$(dirname "$0")/.." && pwd)"

version_matches() {
  local prefix="$1"
  [[ "$fish_version" == "$prefix"* ]]
}

run_suite() {
  bash scripts/test-fish-plugin.sh
}

run_env1_in_docker() {
  docker run --rm     -v "$repo_root:/workspace"     -w /workspace     archlinux:base-devel     bash -lc 'set -euo pipefail; pacman -Syu --noconfirm --needed fish fzf fd python git >/dev/null; bash scripts/test-fish-plugin.sh'
}

run_env3_in_docker() {
  docker run --rm \
    -v "$repo_root:/workspace" \
    -w /workspace \
    debian:12 \
    bash -lc 'set -euo pipefail; apt-get update >/dev/null; DEBIAN_FRONTEND=noninteractive apt-get install -y fish fzf fd-find python3 git >/dev/null; FORGE_SKIP_PTY=1 bash scripts/test-fish-plugin.sh'
}

case "$env_id" in
  ENV-1)
    if [[ "$os_name" != "Linux" ]]; then
      echo "ENV-1 requires Linux; current OS is $os_name" >&2
      exit 2
    fi
    if version_matches "4.6."; then
      echo "Running ENV-1 (Linux fish 4.6.x reference suite)"
      run_suite
    elif command -v docker >/dev/null 2>&1; then
      echo "Running ENV-1 via Arch Linux Docker image (fish 4.6.x reference lane)"
      run_env1_in_docker
    else
      echo "ENV-1 expects fish 4.6.x locally or Docker for the Arch Linux reference runner" >&2
      exit 2
    fi
    ;;
  ENV-2)
    if [[ "$os_name" != "Darwin" ]]; then
      echo "ENV-2 requires macOS; current OS is $os_name" >&2
      exit 2
    fi
    echo "Running ENV-2 (macOS current fish suite)"
    run_suite
    ;;
  ENV-3)
    if version_matches "3.6."; then
      echo "Running ENV-3 (host fish 3.6.x compatibility suite)"
      FORGE_SKIP_PTY=1 bash scripts/test-fish-plugin.sh
    elif command -v docker >/dev/null 2>&1; then
      echo "Running ENV-3 via Debian 12 Docker image (fish 3.6.0; PTY smoke accepted exception)"
      run_env3_in_docker
    else
      echo "ENV-3 requires fish 3.6.x or Docker for the Debian 12 compatibility runner" >&2
      exit 2
    fi
    ;;
  *)
    echo "Unknown environment id: $env_id" >&2
    exit 1
    ;;
esac
