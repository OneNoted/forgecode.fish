#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <package-name> <aur-repo-url>" >&2
  exit 2
fi

package_name="$1"
aur_repo_url="$2"
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
source_dir="$repo_root/packaging/aur/$package_name"

if [[ ! -d "$source_dir" || ! -f "$source_dir/PKGBUILD" ]]; then
  echo "missing packaging directory for $package_name" >&2
  exit 1
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

git clone "$aur_repo_url" "$workdir/repo"
find "$workdir/repo" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
rsync -a --delete --exclude '.git' "$source_dir/" "$workdir/repo/"

cd "$workdir/repo"
git config user.name "${AUR_PACKAGER_NAME:-forgecode.fish Release Bot}"
git config user.email "${AUR_PACKAGER_EMAIL:-forgecode-fish-release-bot@users.noreply.github.com}"
git add -A
if git diff --cached --quiet; then
  echo "No AUR changes to push for $package_name"
  exit 0
fi

git commit -m "Update $package_name from GitHub"
git push origin HEAD
