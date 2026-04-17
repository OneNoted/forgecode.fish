#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
status=0
shopt -s nullglob

for pkgdir in "$repo_root"/packaging/aur/*; do
  [[ -f "$pkgdir/PKGBUILD" ]] || continue
  echo "Checking $(basename "$pkgdir")"
  bash -n "$pkgdir/PKGBUILD"

  if command -v namcap >/dev/null 2>&1; then
    if ! namcap "$pkgdir/PKGBUILD"; then
      status=1
    fi
  fi

done

exit "$status"
