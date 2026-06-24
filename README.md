# Workstation

This image is a collection of tools that are useful for CI/CD pipelines for Kubernetes clusters. Some pipeline jobs need git and kubectl; others need helm and kubectl; and others need git, terraform, and AWS CLI. Rather than maintaining a fleet of images with every permutation of tools needed for each particular job, we just have this one, big image with everything in it. A complete DevOps workstation in an image.

To save a little space, the image has different versions for different cloud service providers (CSPs), but we may merge all CSP tools back into one image later if there's demand for it.

## How to Use This Image

### Fork This Repo

Running random code you found on the Internet is not safe. You should fork this repo, review it yourself, and review again whenever you fetch upstream.

1. Fork this repo.
2. Clone repo on your computer.
3. Set an upstream remote so you can pull changes when you wish:
   ```
   git remote add upstream https://gitlab.com/dedevsecops/workstation.git
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

https://gitlab.com/dedevsecops/k8s-eks-template/blob/master/.gitlab-ci.yml

### Humans

You can run this image on your local computer like this:
```
docker run -it --rm registry.gitlab.com/dedevsecops/workstation bash
```

### Agent Sandbox (Claude Code / OpenCode)

You can use the image as a throwaway sandbox for an AI coding agent — [Claude Code](https://claude.com/claude-code) or [OpenCode](https://opencode.ai) — that can only see the directory you launch it in. The container:

- runs as **your own UID/GID**, so files the agent writes are owned by you, not root;
- mounts **only the current directory** (as `/work`) — nothing else;
- gets **no access to `~/.aws`, `~/.kube`, `~/.ssh`, `~/.gnupg`**, any other host directory, or the Docker socket.

The agent gets the full DevOps toolset but none of your credentials, and can only touch the project you launch it in.

First build (or pull) the image. The base image (no cloud CLI) is the natural fit for a sandbox:

```bash
sudo docker build -t workstation .
```

#### One-liner

```bash
mkdir -p .sandbox-home && sudo docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  --security-opt no-new-privileges \
  -v "$PWD:/work" -w /work \
  -e HOME=/work/.sandbox-home -e USER="$(id -un)" \
  workstation claude
```

Swap `claude` for `opencode` to run the other agent. The `.sandbox-home/` directory keeps the agent's auth, config, and history in one place inside the project — add it to your `.gitignore`.

#### Script

[`sandbox.sh`](sandbox.sh) wraps the same command. Copy it next to your project (or onto your `PATH`) and run:

```bash
./sandbox.sh                  # Claude Code (default)
./sandbox.sh opencode         # OpenCode
./sandbox.sh claude --resume  # extra args pass through to the agent
```

It honors a few environment variables:

| Variable            | Default        | Purpose                                                                                 |
| ------------------- | -------------- | --------------------------------------------------------------------------------------- |
| `WORKSTATION_IMAGE` | `workstation`  | Image to run; point at a registry path or a CSP variant like `workstation:aws`.         |
| `DOCKER`            | `sudo docker`  | How to invoke Docker; set `DOCKER=docker` if you run rootless or are in the `docker` group. |
| `ANTHROPIC_API_KEY` | *(unset)*      | If set in your shell, it's forwarded into the container (as an env var, **not** a mounted file) so Claude Code is authenticated without an interactive login. |

#### Notes

- **Authentication.** Either export `ANTHROPIC_API_KEY` before running, or log in interactively the first time — the login is stored under `.sandbox-home/` and persists across runs.
- **Network is open** (the agents need it to reach their APIs); only the filesystem is sandboxed.
- The Docker CLI is in the image but the socket is intentionally **not** mounted, so the agent can't reach your host's Docker daemon.
- Running as a non-root UID relies on Claude Code being installed under `/opt/claude` (world-readable) rather than root's home; this is handled in the `Dockerfile`. If you run an older image that installed it under `/root`, `claude` will fail with a permission error — rebuild it.
