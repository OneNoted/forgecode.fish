#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
shopt -s nullglob

for pkgdir in "$repo_root"/packaging/aur/*; do
  if [[ -f "$pkgdir/PKGBUILD" ]]; then
    echo "Updating $(basename "$pkgdir")/.SRCINFO"
    (
      cd "$pkgdir"
      makepkg --printsrcinfo > .SRCINFO
    )
  fi
done
