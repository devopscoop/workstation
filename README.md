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

You can use the image as a throwaway sandbox for an AI coding agent — [Claude Code](https://claude.com/claude-code) or [OpenCode](https://opencode.ai) — that runs as your own UID/GID, sees only the directory you launch it in, and gets none of your host credentials and no Docker socket. See [`ai_sandbox.sh` in devopscoop/scripts](https://github.com/devopscoop/scripts#ai_sandboxsh) for the script and full documentation.
