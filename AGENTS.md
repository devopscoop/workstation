# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A single Docker image ("workstation") that bundles every tool needed for CI/CD pipelines targeting Kubernetes clusters — kubectl, helm, helmfile, flux, istioctl, kustomize, skaffold, sops, opentofu, tflint, tfsec, trivy, yq, dyff, kubent, Docker, and more. Three CSP-specific variants are built from one Dockerfile using a `CSP` build arg: `aws`, `azure`, `gcp`.

## Building the Image

```bash
# Pick a CSP variant (aws | azure | gcp); omit --build-arg for the base image
docker build --build-arg CSP=aws -t workstation:aws .
docker build --build-arg CSP=azure -t workstation:azure .
docker build --build-arg CSP=gcp  -t workstation:gcp  .
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

| Build arg | Script     | Tools added                            |
| --------- | ---------- | -------------------------------------- |
| `aws`     | `aws.sh`   | AWS CLI, aws-iam-authenticator, eksctl |
| `azure`   | `azure.sh` | Azure CLI (via Microsoft apt repo)     |
| `gcp`     | *(inline)* | Google Cloud SDK tarball               |

If no `CSP` arg is passed, none of those `RUN if [[ "${CSP}" = ... ]]` blocks execute — you get the base image only.

## CI/CD

**GitLab** (`.gitlab-ci.yml`): On every push to the default branch, three jobs (`build_aws`, `build_azure`, `build_gcp`) each build, tag, and push their variant to the GitLab container registry with two tags: `<short-sha>-<csp>` and `<csp>`.

**GitHub Actions** (`.github/workflows/ghaups-daily.yml`): A daily scheduled workflow uses [ghaups](https://github.com/devopscoop/ghaups) to pin all workflow action references to SHA hashes and opens a PR with the changes. It uses a GitHub App token (vars: `GHAUPS_APP_ID`, secrets: `GHAUPS_APP_PRIVATE_KEY`) rather than the default `GITHUB_TOKEN` because pinning requires the `workflows` permission.

## .profile

Copied into the image and symlinked as `.bash_profile`. It runs on interactive container startup and:

- Sources `/mnt/env.sh` if present (sets `CLUSTER_NAME` and kubeconfig for interactive cluster sessions)
- Starts `gpg-agent` with SSH support
- Initializes Google Cloud SDK path/completion if installed
- Sets up kubectl bash completion with `k` alias
- Sets `tf` alias for `tofu`/`terraform`
