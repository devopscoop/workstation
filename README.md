# Workstation

This image is a collection of tools that are useful for CI/CD pipelines for Kubernetes clusters. Some pipeline jobs need git and kubectl; others need helm and kubectl; and others need git, terraform, and AWS CLI. Rather than maintaining a fleet of images with every permutation of tools needed for each particular job, we just have this one, big image with everything in it. A complete DevOps workstation in an image.

To save a little space, the image has different versions for different cloud service providers (CSPs), but we may merge all CSP tools back into one image later if there's demand for it.

## Prerequisites

Everything in this repo runs inside the image, so the only local tools you need are Docker, git, and (for the maintainer scripts) bash and curl. Package manifests are included:

- macOS, using [Homebrew](https://brew.sh/) and the `Brewfile`:

  ```shell
  brew bundle
  ```

- Arch Linux, using the `pkglist.txt` (all packages are in the official repos):

  ```shell
  grep -vE '^(#|$)' pkglist.txt | sudo pacman -S --needed -
  ```

On other operating systems, install Docker and git manually.

## How to Use This Image

### Fork This Repo

Running random code you found on the Internet is not safe. You should fork this repo, review it yourself, and review again whenever you fetch upstream.

1. Fork this repo.
2. Clone repo on your computer.
3. Set an upstream remote so you can pull changes when you wish:
   ```
   git remote add upstream https://gitlab.com/devopscoop/workstation.git
   ```
4. Whenever you wish to update your fork, run this:
   ```
   git fetch upstream
   git checkout master
   git merge upstream/master
   git push
   ```

### CI/CD Workers

To use it as a CI/CD worker with GitLab, just set your pipeline image to this Docker image. For an example, see the `image:` line in here:

https://gitlab.com/devopscoop/k8s-eks-template/blob/master/.gitlab-ci.yml

### Humans

You can run this image on your local computer like this:
```
docker run -it --rm registry.gitlab.com/devopscoop/workstation bash
```

### Agent Sandbox (Claude Code / OpenCode)

You can use the image as a throwaway sandbox for an AI coding agent — [Claude Code](https://claude.com/claude-code) or [OpenCode](https://opencode.ai) — that can only see the directory you launch it in. The container:

- runs as **your own UID/GID**, so files the agent writes are owned by you, not root;
- mounts **only the current directory** (as `/work/<dirname>`) plus a shared sandbox home (`~/.sandbox-home`) for agent state — nothing else;
- gets **no access to `~/.aws`, `~/.kube`, `~/.ssh`, `~/.gnupg`, your real `~/.claude`**, any other host directory, or the Docker socket.

The agent gets the full DevOps toolset but none of your credentials, and can only touch the project you launch it in.

First pull (or build) the image:

```bash
# Pull the pre-built AWS variant from GitLab (recommended)
sudo docker pull ghcr.io/devopscoop/workstation:main-aws

# Or build locally (omit --build-arg for the base image, no cloud CLI)
sudo docker build --build-arg CSP=aws -t workstation:aws .
```

#### One-liner

```bash
mkdir -p ~/.sandbox-home && sudo docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  --security-opt no-new-privileges \
  -v "$HOME/.sandbox-home:/sandbox-home" \
  -v "$PWD:/work/$(basename "$PWD")" -w "/work/$(basename "$PWD")" \
  -e HOME=/sandbox-home -e USER="$(id -un)" \
  ghcr.io/devopscoop/workstation:main-aws claude
```

Swap `claude` for `opencode` to run the other agent. The `~/.sandbox-home/` directory keeps the agents' auth, config, and history in one place on the host, shared by every project's sandbox — so you log in once, not once per project. It is deliberately **not** your real `~/.claude` (the sandbox must never touch your laptop's config; on macOS the OAuth token lives in the Keychain anyway). The project mounts at `/work/<dirname>` rather than a fixed `/work` so Claude Code keeps trust, history, and `--resume` separate per project.

#### Script

The [`ai_sandbox.sh`](https://github.com/devopscoop/scripts/blob/main/ai_sandbox.sh) script in [devopscoop/scripts](https://github.com/devopscoop/scripts) wraps the same command — copy it onto your `PATH` and run it from a project root:

```bash
ai_sandbox.sh                  # Claude Code (default)
ai_sandbox.sh opencode         # OpenCode
ai_sandbox.sh claude --resume  # extra args pass through to the agent
```

Its environment knobs (`IMAGE`, `DOCKER`, `SANDBOX_HOME`, `ANTHROPIC_API_KEY`) are documented in that repo's README.

#### Notes

- **Authentication.** Either export `ANTHROPIC_API_KEY` before running, or log in interactively the first time — the login is stored under `~/.sandbox-home/` on the host and persists across runs *and* projects.
- **Sharing trade-off.** Because every project's sandbox shares `~/.sandbox-home`, an agent in one project can read state (including credentials and settings) an agent left there from another project. If a project is untrusted enough that this matters, run it with its own `SANDBOX_HOME`.
- **Network is open** (the agents need it to reach their APIs); only the filesystem is sandboxed.
- The Docker CLI is in the image but the socket is intentionally **not** mounted, so the agent can't reach your host's Docker daemon.
- Running as a non-root UID relies on Claude Code being installed under `/opt/claude` (world-readable) rather than root's home; this is handled in the `Dockerfile`. If you run an older image that installed it under `/root`, `claude` will fail with a permission error — rebuild it.
