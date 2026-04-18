# AUR packaging

This directory is the source of truth for forgecode.nu AUR packages.

Packages:

- `forgecode-nu`: installs the tagged source release into Nushell's vendor autoload path.
  Bump `pkgver`, create the GitHub release tag, update the source archive checksum from the published tarball, regenerate `.SRCINFO`, then publish from `main`.
- `forgecode-nu-git`: packages the current git HEAD into the same Nushell autoload layout.
  Use this for tracking the moving development branch between tagged releases.

## Package layout

Both packages install:

- autoload shim → `/usr/share/nushell/vendor/autoload/forgecode.nu`
- source tree → `/usr/share/forgecode.nu/`
- top-level docs → `/usr/share/doc/<pkgname>/`
- license → `/usr/share/licenses/<pkgname>/LICENSE`

## Publish flow

1. Make sure the upstream repo URL in each `PKGBUILD` matches the actual published GitHub repo.
2. For a stable release:
   - bump `packaging/aur/forgecode-nu/PKGBUILD` `pkgver`
   - create the matching GitHub release tag
   - update the release archive checksum in `sha256sums` from the published tarball
3. Regenerate `.SRCINFO` in each package directory:

   ```bash
   cd packaging/aur/forgecode-nu && makepkg --printsrcinfo > .SRCINFO
   cd packaging/aur/forgecode-nu-git && makepkg --printsrcinfo > .SRCINFO
   ```

4. Sync each directory into its matching AUR git repo and push.

## Current assumptions to verify before first publish

- The upstream public repository URL is assumed to be `https://github.com/OneNoted/forgecode.nu`.
- The Arch package names are `forgecode-nu` and `forgecode-nu-git`.
- The project license is Apache-2.0 and the package metadata should stay aligned with the top-level `LICENSE` file.

## GitHub-driven publishing

The intended release path is GitHub-first:

- tracked package metadata lives in `packaging/aur/`
- `.github/workflows/aur.yml` validates PKGBUILDs and `.SRCINFO`
- `forgecode-nu-git` can publish from `main` or manual dispatch
- `forgecode-nu` publishes from manual dispatch on `main` after the matching release tag exists and its checksum is recorded in tracked metadata

Required GitHub secrets:

- `AUR_SSH_PRIVATE_KEY`
- `AUR_PACKAGER_NAME` (optional)
- `AUR_PACKAGER_EMAIL` (optional)
