# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> `CLAUDE.md` is a **symlink to `AGENTS.md`** — one file, two names, so Claude Code and other agents read the same guidance. Edit `AGENTS.md`. If `CLAUDE.md` ever shows up as a regular file (`git status` reports a `T` type change), restore it with `ln -sf AGENTS.md CLAUDE.md` instead of letting the two copies drift.

## What This Repo Is

A single Docker image ("workstation") that bundles every tool needed for CI/CD pipelines targeting Kubernetes clusters — kubectl, helm, helmfile, flux, istioctl, kustomize, skaffold, sops, opentofu, tflint, tfsec, trivy, yq, dyff, kubent, Docker, Claude Code, OpenCode, and more. Four CSP-specific variants are built from one Dockerfile using a `CSP` build arg: `aws`, `azure`, `gcp`, `digitalocean`.

There is no test suite and nothing to lint — the build *is* the test. Verify a change by building the affected variant(s).

## Building the Image

```bash
# Pick a CSP variant (aws | azure | gcp | digitalocean); omit --build-arg for the base image
docker build --build-arg CSP=aws          -t workstation:aws          .
docker build --build-arg CSP=azure        -t workstation:azure        .
docker build --build-arg CSP=gcp          -t workstation:gcp          .
docker build --build-arg CSP=digitalocean -t workstation:digitalocean .
```

Run interactively:

```bash
docker run -it --rm workstation:aws bash
```

## Updating Tool Versions

`update.sh` queries each tool's GitHub releases page and prints a fresh block of `ENV` lines. Copy-paste the output between the two `# =====` marker comments in the Dockerfile:

```bash
./update.sh
```

Two versions are **hardcoded** in `update.sh` because they can't be resolved automatically, and they are **stale on purpose** — pasting the output verbatim silently *downgrades* them. Look these up by hand and carry the Dockerfile's current values forward:

- `AWS_CLI_VERSION` — https://github.com/aws/aws-cli/tags (AWS doesn't publish GitHub releases)
- `KUSTOMIZE_VERSION` — https://github.com/kubernetes-sigs/kustomize/releases (repo has multiple products; "latest" is unreliable)

Several tools have moved orgs and are downloaded from their old URL, relying on a GitHub redirect (sops: `mozilla` → `getsops`, tfsec: `tfsec` → `aquasecurity`, eksctl: `weaveworks` → `eksctl-io`). `update.sh` already queries the new org. If a download 404s, the redirect is gone — update the URL in the Dockerfile.

## Adding or Bumping a Tool in the Image

Conventions in the Dockerfile that exist for a reason — follow them:

- **Pin the version as an `ENV *_VERSION=`** inside the `# =====` markers, and template the download off it. Never fetch "latest" at build time.
- **Download with the hardened `wget` idiom** (`-nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O <file>`), landing tarballs in a file before extracting. A `curl | tar` pipe can't recover from the mid-stream CDN stalls these runners see — the bytes are gone and the failure hides behind the pipe.
- **Azure Front Door hosts are the exception**: `get.helm.sh` and `packages.microsoft.com` return intermittent SSL failures and rot through IPv6, and `wget --retry-connrefused` won't retry an SSL error. Those two use `curl -4 ... --retry-all-errors` instead. Mirror that pattern for any new Azure-CDN-hosted download.
- **Check the arch token** (see Multi-arch below).
- **`.dockerignore` is an allowlist** — `*` followed by `!.profile`, `!aws.sh`, `!azure.sh`. Any new file you `COPY` into the image must be un-ignored there or the build fails on a missing file.
- Helm plugins need `--verify=false`: Helm 4 defaults `--verify` to true, and these community plugins ship no signatures.

## CSP-Specific Installation

CSP layers are isolated at the bottom of the Dockerfile so all preceding layers are shared across variants:

| Build arg      | Script     | Tools added                        |
| -------------- | ---------- | ---------------------------------- |
| `aws`          | `aws.sh`   | AWS CLI, eksctl                    |
| `azure`        | `azure.sh` | Azure CLI (via Microsoft apt repo) |
| `gcp`          | *(inline)* | Google Cloud SDK tarball           |
| `digitalocean` | *(inline)* | doctl (DigitalOcean CLI)           |

If no `CSP` arg is passed, none of those `RUN if [[ "${CSP}" = ... ]]` blocks execute — you get the base image only.

`azure.sh` pins the Microsoft apt suite to `AZ_REPO=noble` rather than using `lsb_release -cs`: the azure-cli repo lags Ubuntu releases and publishes no `Release` file for the newer base image's codename. Bump it when Microsoft ships a newer suite.

## Multi-arch

**Both pipelines currently build `linux/amd64` only.** arm64 support is fully wired up but switched off — GitHub Actions has the multi-arch line commented out just below the active `platforms:` line in `docker-build.yml`, and GitLab has a `PLATFORMS` variable in `.gitlab-ci.yml`. QEMU and buildx setup remain in place in both, so re-enabling arm64 is a one-line change. Don't describe the published images as multi-arch until it's flipped back on.

The Dockerfile itself stays arch-agnostic: BuildKit's `TARGETARCH` is normalized to an `ENV` near the top (defaulting to `amd64` for classic builders like GitLab's that don't set it), and every download templates its arch off it. Most tools use Go-style `amd64`/`arm64`, but a few don't and are mapped inline: trivy (`64bit`/`ARM64`), opencode (`x64`/`arm64`), gcloud (`x86_64`/`arm`), and the AWS CLI (`x86_64`/`aarch64`, in `aws.sh`). **When bumping a tool, check its arch token still matches** — if a project renames its release assets, update the mapping.

## CI/CD

**GitLab** (`.gitlab-ci.yml`): On every push to the default branch, four jobs (`build_aws`, `build_azure`, `build_gcp`, `build_digitalocean`) extend a shared `.build` template and each build, tag, and push their variant to the GitLab container registry with two tags: `<short-sha>-<csp>` and `<csp>`. Note this pipeline has **no base-image job** — only the four CSP variants.

**GitHub Actions — build** (`.github/workflows/docker-build.yml`): On pushes to `main`/`dev`, `v*` tags, and PRs, a single `build-image` job fans out over a `csp` matrix (`""`, `aws`, `azure`, `gcp`, `digitalocean`) to build reproducibly and push to GHCR with provenance/SBOM attestations and a Trivy scan. The empty matrix value is the base image (no cloud CLI). PRs build but don't push, and skip attestations and cache writes. Tags are CSP-scoped via a metadata-action `suffix` (e.g. `-aws`; empty for base) so variants don't clobber each other, and build cache is likewise per-CSP (`:buildcache<suffix>`). The `build-<sha7>-<commit-timestamp>` tag format feeds FluxCD image automation, and that same commit timestamp is reused as `SOURCE_DATE_EPOCH` for reproducible builds.

**GitHub Actions — Claude** (`claude.yml`, `claude-code-review.yml`): Both pin `--model claude-opus-5 --effort xhigh` so CI doesn't drift with CLI defaults, and both pin action refs to SHAs. They run in two *different* modes of `claude-code-action`, which is the thing to understand before editing them:

- `claude.yml` is **tag mode** — triggered by `@claude` in an issue or PR comment. It passes no prompt, so the action builds its own tool list and the Bash tool stays disabled. It has `contents: write` to push a work branch, but returns a prefilled PR link for a human to submit rather than opening the PR itself.
- `claude-code-review.yml` is **agent mode** — it passes a `prompt`, which means allowed tools come *only* from `claude_args`. The `--allowed-tools` list is **required, not optional**: the inline-comment MCP server is registered only when the list contains an `mcp__github_inline_comment__` entry, so dropping it produces a job that reviews the code, has no way to report, and silently posts nothing. For the same reason the `code-review` plugin is deliberately not used here — it reports via `ReportFindings`, which this action doesn't handle.

Action SHA pinning used to be automated by a daily `ghaups` workflow; that was removed in July 2026, so pins are now maintained by Dependabot and by hand. (`.github/dependabot.yml` is still an unconfigured stub — `package-ecosystem: ""` — so it does nothing until filled in.)

## Agent Sandbox

`sandbox.sh` runs Claude Code or OpenCode inside the image as a throwaway sandbox: your own UID/GID, only `$PWD` mounted (as `/work`), no `~/.aws`/`~/.kube`/`~/.ssh`/`~/.gnupg`, and no Docker socket. Agent state lives in a gitignorable `.sandbox-home/` in the project. Network is open — only the filesystem is sandboxed. Knobs: `WORKSTATION_IMAGE`, `DOCKER` (defaults to `sudo docker`), `ANTHROPIC_API_KEY` (forwarded as an env var, never a mounted file).

This couples to the Dockerfile: Claude Code is installed with `HOME=/opt/claude` and symlinked onto `PATH`, specifically so an arbitrary `--user` UID can read it without poking a hole in `/root`'s `0700`. **Don't "simplify" that back to a root-home install** — it breaks every non-root run. The install is followed by `claude --version` because `claude install` exits 0 without installing anything when updates are disabled, which would otherwise leave a dangling symlink and a green build with no `claude` in the image.

## .profile

Copied into the image and symlinked as `.bash_profile` (a workaround from an old Alpine base that stopped sourcing `.profile`). It runs on interactive container startup and:

- Sources `/mnt/env.sh` if present (sets `CLUSTER_NAME` and kubeconfig for interactive cluster sessions)
- Starts `gpg-agent` with SSH support
- Initializes Google Cloud SDK path/completion if installed (from `/root/google-cloud-sdk`, where the gcp variant untars it)
- Sets up kubectl bash completion with the `k` alias
- Sets `alias tf=terraform` — note the image installs **opentofu (`tofu`)**, not terraform, so this alias is currently dead

## Package manifests

This repo ships a `Brewfile` (macOS: `brew bundle`) and a `pkglist.txt` (Arch Linux) that install the HOST-side tools (Docker, git, bash, curl). Keep them in sync with the code:

- Tools added to the image via the Dockerfile run inside the container and do NOT belong in the manifests — their versions are pinned as `ENV *_VERSION=` in the Dockerfile and bumped by update.sh.
- If you add a script or step a human runs on the host, add its tools to BOTH files, with a comment noting what uses it; remove entries when a tool stops being used.
- Verify package names before adding them: `brew info <formula>` for Homebrew, and the official repos/AUR for Arch. If a package is AUR-only, note that in pkglist.txt's header instructions.
- Update the "Prerequisites" section in README.md if the tool list changes.
