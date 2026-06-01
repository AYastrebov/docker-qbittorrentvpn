# Auto qBittorrent Version Bump Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a GitHub Actions workflow that checks daily for new qBittorrent releases, and when found, bumps the Dockerfile, commits, tags, and builds/pushes the Docker image.

**Architecture:** Single workflow file `.github/workflows/check-update.yml` that fetches qBittorrent tags from GitHub API, compares against Dockerfile ARG, and if newer runs the full multi-arch build. Self-contained build step avoids GITHUB_TOKEN recursion limitations. No changes to existing files.

**Tech Stack:** GitHub Actions, Docker Buildx, Trivy SARIF scanning

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `.github/workflows/check-update.yml` | Create | Full auto-update workflow |
| `Dockerfile` | None | Read for version; modified at runtime by the workflow |

No existing files are modified.

---

### Task 1: Create the check-update workflow

**File:**
- Create: `.github/workflows/check-update.yml`

- [ ] **Step 1: Write the workflow file**

```yaml
name: Check qBittorrent Update & Build

on:
  schedule:
    - cron: '0 6 * * *'
  workflow_dispatch:

permissions:
  contents: write
  packages: write
  security-events: write

concurrency:
  group: check-update
  cancel-in-progress: true

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  check-and-build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Get current version from Dockerfile
        id: current
        run: |
          version=$(sed -n 's/^ARG QBITTORRENT_VERSION=\(.*\)/\1/p' Dockerfile)
          echo "version=$version" >> "$GITHUB_OUTPUT"

      - name: Get latest qBittorrent version from GitHub tags
        id: latest
        run: |
          latest=$(curl -sSL "https://api.github.com/repos/qbittorrent/qBittorrent/tags" \
            | jq -r '[.[] | select(.name | test("^(release-)?v?[0-9]+\\.[0-9]+\\.[0-9]+$")) | .name] | first' \
            | sed -E 's/^(release-)?v//')
          echo "version=$latest" >> "$GITHUB_OUTPUT"

      - name: Compare versions
        id: compare
        run: |
          if [ "$(printf '%s\n' "${{ steps.current.outputs.version }}" "${{ steps.latest.outputs.version }}" | sort -V | tail -n1)" != "${{ steps.current.outputs.version }}" ]; then
            echo "changed=true" >> "$GITHUB_OUTPUT"
          else
            echo "changed=false" >> "$GITHUB_OUTPUT"
          fi

      - name: Update Dockerfile ARG
        if: steps.compare.outputs.changed == 'true'
        run: |
          sed -i "s/^ARG QBITTORRENT_VERSION=.*$/ARG QBITTORRENT_VERSION=${{ steps.latest.outputs.version }}/" Dockerfile

      - name: Commit and tag
        if: steps.compare.outputs.changed == 'true'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add Dockerfile
          git commit -m "Bump to ${{ steps.latest.outputs.version }}"
          git tag "v${{ steps.latest.outputs.version }}"
          git push origin master --tags

      - name: Log in to ghcr.io
        if: steps.compare.outputs.changed == 'true'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract Docker metadata
        id: meta
        if: steps.compare.outputs.changed == 'true'
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=semver,pattern={{major}}
            type=raw,value=latest

      - name: Set up QEMU
        if: steps.compare.outputs.changed == 'true'
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        if: steps.compare.outputs.changed == 'true'
        uses: docker/setup-buildx-action@v3
        with:
          platforms: linux/amd64,linux/arm64
          config-inline: |
            [worker.oci]
              max-parallelism = 2

      - name: Build and push
        if: steps.compare.outputs.changed == 'true'
        uses: docker/build-push-action@v6
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha,scope=${{ github.workflow }}
          cache-to: type=gha,mode=max,scope=${{ github.workflow }}
          build-args: |
            BUILDKIT_INLINE_CACHE=1
          outputs: type=registry
          provenance: false
          sbom: false

      - name: Run Trivy vulnerability scanner
        if: steps.compare.outputs.changed == 'true'
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.latest.outputs.version }}
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results to GitHub Security tab
        if: always() && steps.compare.outputs.changed == 'true'
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'
```

- [ ] **Step 2: Verify YAML syntax**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/check-update.yml'))" && echo "YAML syntax OK"
```

- [ ] **Step 3: Verify the Dockerfile ARG line matches the parse regex**

```bash
grep -oP '^ARG QBITTORRENT_VERSION=.*' Dockerfile
```

- [ ] **Step 4: Verify `sort -V` comparison logic works correctly locally**

```bash
# Should say "bump" when latest > current
CURRENT="5.2.1" LATEST="5.3.0" bash -c 'if [ "$(printf "%s\n" "$CURRENT" "$LATEST" | sort -V | tail -n1)" != "$CURRENT" ]; then echo "bump"; else echo "no bump"; fi'
```

```bash
# Should say "no bump" when current >= latest
CURRENT="5.2.1" LATEST="5.2.1" bash -c 'if [ "$(printf "%s\n" "$CURRENT" "$LATEST" | sort -V | tail -n1)" != "$CURRENT" ]; then echo "bump"; else echo "no bump"; fi'
```

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/check-update.yml
git add docs/superpowers/plans/2026-06-01-auto-qbittorrent-version-bump.md
git add docs/superpowers/specs/2026-06-01-auto-qbittorrent-version-bump-design.md
git commit -m "feat: add auto qBittorrent version bump workflow"
```
