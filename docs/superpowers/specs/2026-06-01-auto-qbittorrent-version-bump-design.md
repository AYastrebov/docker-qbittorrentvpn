# Auto qBittorrent Version Bump & Build

## Problem

When a new qBittorrent release comes out, the Docker ARG `QBITTORRENT_VERSION` in `Dockerfile:24` must be updated manually, then committed, tagged, and pushed to trigger the CI build. This is mechanical, repetitive, and easy to forget.

## Goal

A fully automated workflow that checks daily for new qBittorrent releases and, when one is found, bumps the version, commits, tags, and builds/pushes the Docker image — all without human intervention.

## Non-goals

- No separate `VERSION` file (keeps single source of truth in `Dockerfile`)
- No GitHub Release creation (tag + image push is sufficient)
- No changes to the existing `docker-build.yml` workflow (it remains for manual tag-push and manual-dispatch usage)
- No SOCKS5/proxy features or other unrelated changes

## Design

### New file: `.github/workflows/check-update.yml`

A single GitHub Actions workflow that runs on a daily schedule and is also manually dispatchable.

### Triggers

| Trigger | Purpose |
|---------|---------|
| `schedule: 0 6 * * *` | Daily at 06:00 UTC |
| `workflow_dispatch` | Manual trigger for testing or immediate check |

### Permissions

```
contents: write        # push commits and tags
packages: write        # push images to ghcr.io
security-events: write # upload Trivy SARIF results
```

### Job: `check-and-build`

Single job, sequential steps, gated by a `changed` flag.

#### Step 1 — Get current version

Parse the existing Dockerfile with `sed` to extract the current `QBITTORRENT_VERSION`.

```
sed -n 's/^ARG QBITTORRENT_VERSION=\(.*\)/\1/p' Dockerfile
```

Output: `steps.current.outputs.version`

#### Step 2 — Get latest upstream version

Fetch tags from `api.github.com/repos/qbittorrent/qBittorrent/tags`. Filter for stable semver patterns (`release-X.Y.Z`, `vX.Y.Z`, `X.Y.Z`). Take the first (newest since the API returns them in commit-date order). Strip the `release-`/`v` prefix.

```
curl -sSL "https://api.github.com/repos/qbittorrent/qBittorrent/tags" \
  | jq -r '[.[] | select(.name | test("^(release-)?v?[0-9]+\\.[0-9]+\\.[0-9]+$")) | .name] | first' \
  | sed -E 's/^(release-)?v//'
```

Output: `steps.latest.outputs.version`

#### Step 3 — Compare

Use `sort -V` to determine whether the upstream version is strictly greater than the current version. Only proceed if `changed=true`.

```
if [ "$(printf '%s\n' "$current" "$latest" | sort -V | tail -n1)" != "$current" ]; then
  echo "changed=true"
fi
```

#### Step 4 — Update Dockerfile

Replace the ARG line in-place.

```
sed -i "s/^ARG QBITTORRENT_VERSION=.*$/ARG QBITTORRENT_VERSION=$version/" Dockerfile
```

#### Step 5 — Commit and tag

Configure `git config` as `github-actions[bot]`, commit `Dockerfile` with message `"Bump to X.Y.Z"`, create annotated tag `vX.Y.Z`, push both to `origin master`.

#### Step 6 — Docker build (multi-arch)

Reuse the same build configuration as `docker-build.yml`:

- Set up QEMU and Buildx
- Log in to ghcr.io using `GITHUB_TOKEN`
- Generate Docker tags: `X.Y.Z`, `X.Y`, `X`, `latest`
- Build and push for `linux/amd64,linux/arm64`
- Cache via `type=gha`

#### Step 7 — Vulnerability scan

Run Trivy on the newly pushed image and upload SARIF to GitHub Security tab.

### Edge cases

| Case | Behavior |
|------|----------|
| API rate-limited or fails | Step 2 fails, job stops — no accidental bump |
| Version already current | Step 3 sets `changed=false`, remaining steps skipped |
| Tag `vX.Y.Z` already exists | `git push` fails with clear error — harmless |
| Dockerfile was already bumped manually since the check started | `git push` is a fast-forward — standard behavior |
| Upstream tag uses `release-X.Y.Z` format | `sed` strips `release-` prefix |
| Pre-release tags (e.g. `v5.3.0-alpha1`) | `jq` filter excludes them (not semver strict) |
| Upstream version appears higher but is actually a downgrade (e.g., backport) | `sort -V` comparison prevents downgrade |

### File changes

| File | Action |
|------|--------|
| `.github/workflows/check-update.yml` | **Create** — the auto-update workflow |
| `docs/superpowers/specs/2026-06-01-auto-qbittorrent-version-bump-design.md` | **Create** — this design doc |

No other files are modified. The existing `Dockerfile` remains the single source of truth for version.

## Why this approach

- **Single workflow**: no separate scripts, no VERSION file, no reusable workflow patterns
- **Self-contained build**: avoids the GITHUB_TOKEN limitation where tag pushes don't trigger downstream workflows
- **Familiar patterns**: mirrors the existing `docker-build.yml` build steps exactly
- **Fail-safe**: every guard (`changed` flag, `sort -V` comparison, API error) prevents accidental bumps
