# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A single Docker image ("workstation") that bundles every tool needed for CI/CD pipelines targeting Kubernetes clusters — kubectl, helm, helmfile, flux, istioctl, kustomize, skaffold, sops, opentofu, tflint, tfsec, trivy, yq, dyff, kubent, Docker, Claude Code, OpenCode, and more. Four CSP-specific variants are built from one Dockerfile using a `CSP` build arg: `aws`, `azure`, `gcp`, `digitalocean`.

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

Two versions require **manual lookup** (noted in both `update.sh` and the Dockerfile):

- `AWS_CLI_VERSION` — check https://github.com/aws/aws-cli/tags
- `KUSTOMIZE_VERSION` — check https://github.com/kubernetes-sigs/kustomize/releases (repo has multiple products; "latest" is unreliable)

## CSP-Specific Installation

CSP layers are isolated at the bottom of the Dockerfile so all preceding layers are shared across variants:

| Build arg      | Script     | Tools added                            |
| -------------- | ---------- | -------------------------------------- |
| `aws`          | `aws.sh`   | AWS CLI, aws-iam-authenticator, eksctl |
| `azure`        | `azure.sh` | Azure CLI (via Microsoft apt repo)     |
| `gcp`          | *(inline)* | Google Cloud SDK tarball               |
| `digitalocean` | *(inline)* | doctl (DigitalOcean CLI)               |

If no `CSP` arg is passed, none of those `RUN if [[ "${CSP}" = ... ]]` blocks execute — you get the base image only.

## Multi-arch

The image builds for both `linux/amd64` and `linux/arm64`. BuildKit's `TARGETARCH` is normalized to an `ENV` near the top of the Dockerfile (defaulting to `amd64` for classic builders like GitLab's that don't set it), and every download templates its arch off it. Most tools use Go-style `amd64`/`arm64`, but a few don't and are mapped inline: trivy (`64bit`/`ARM64`), opencode (`x64`/`arm64`), gcloud (`x86_64`/`arm`), and the AWS CLI (`x86_64`/`aarch64`, in `aws.sh`). **When bumping a tool, check its arch token still matches** — if a project renames its release assets, update the mapping.

## CI/CD

**GitLab** (`.gitlab-ci.yml`): On every push to the default branch, four jobs (`build_aws`, `build_azure`, `build_gcp`, `build_digitalocean`) each build, tag, and push their variant to the GitLab container registry with two tags: `<short-sha>-<csp>` and `<csp>`.

**GitHub Actions — build** (`.github/workflows/docker-build.yml`): On pushes to `main`/`dev`, `v*` tags, and PRs, a single `build-image` job fans out over a `csp` matrix (`""`, `aws`, `azure`, `gcp`, `digitalocean`) to build, multi-arch (amd64 + arm64 on real pushes), reproducibly, and push to GHCR with provenance/SBOM attestations and a Trivy scan. The empty matrix value is the base image (no cloud CLI). Tags are CSP-scoped via a metadata-action `suffix` (e.g. `-aws`; empty for base) so variants don't clobber each other, and build cache is likewise per-CSP (`:buildcache<suffix>`).

**GitHub Actions — ghaups** (`.github/workflows/ghaups-daily.yml`): A daily scheduled workflow uses [ghaups](https://github.com/devopscoop/ghaups) to pin all workflow action references to SHA hashes and opens a PR with the changes. It uses a GitHub App token (vars: `GHAUPS_APP_ID`, secrets: `GHAUPS_APP_PRIVATE_KEY`) rather than the default `GITHUB_TOKEN` because pinning requires the `workflows` permission.

## .profile

Copied into the image and symlinked as `.bash_profile`. It runs on interactive container startup and:

- Sources `/mnt/env.sh` if present (sets `CLUSTER_NAME` and kubeconfig for interactive cluster sessions)
- Starts `gpg-agent` with SSH support
- Initializes Google Cloud SDK path/completion if installed
- Sets up kubectl bash completion with `k` alias
- Sets `tf` alias for `tofu`/`terraform`
