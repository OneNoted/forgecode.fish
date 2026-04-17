# AUR packaging

This directory is the source of truth for forgecode.fish AUR packages.

Packages:

- `forgecode-fish`: installs the tagged source release into fish's vendor plugin paths.
  Bump `pkgver`, update the source archive checksum, and regenerate `.SRCINFO` for each stable release.
- `forgecode-fish-git`: packages the current git HEAD into the same fish vendor paths.
  Use this for tracking the moving development branch between tagged releases.

## Package layout

Both packages install:

- `conf.d/forgecode.fish` → `/usr/share/fish/vendor_conf.d/forgecode.fish`
- `functions/*.fish` → `/usr/share/fish/vendor_functions.d/`
- `completions/forge.fish` → `/usr/share/fish/vendor_completions.d/forge.fish`
- top-level docs → `/usr/share/doc/<pkgname>/`

## Publish flow

1. Make sure the upstream repo URL in each `PKGBUILD` matches the actual published GitHub repo.
2. For a stable tag, bump `packaging/aur/forgecode-fish/PKGBUILD`:
   - `pkgver`
   - release archive checksum in `sha256sums`
3. Regenerate `.SRCINFO` in each package directory:

   ```bash
   cd packaging/aur/forgecode-fish && makepkg --printsrcinfo > .SRCINFO
   cd packaging/aur/forgecode-fish-git && makepkg --printsrcinfo > .SRCINFO
   ```

4. Sync each directory into its matching AUR git repo and push.

## Current assumptions to verify before first publish

- The upstream public repository URL is assumed to be `https://github.com/OneNoted/forgecode.fish`.
- The Arch package names are `forgecode-fish` and `forgecode-fish-git`.
- The project license is Apache-2.0 and the package metadata should stay aligned with the top-level `LICENSE` file.


## GitHub-driven publishing

The intended release path is GitHub-first:

- tracked package metadata lives in `packaging/aur/`
- `.github/workflows/aur.yml` validates PKGBUILDs and `.SRCINFO`
- `forgecode-fish-git` can publish from `main` or manual dispatch
- `forgecode-fish` publishes from a release tag or manual dispatch once its checksum is no longer `SKIP`

Required GitHub secrets:

- `AUR_SSH_PRIVATE_KEY`
- `AUR_PACKAGER_NAME` (optional)
- `AUR_PACKAGER_EMAIL` (optional)
