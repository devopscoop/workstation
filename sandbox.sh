#!/usr/bin/env bash
#
# Run Claude Code or OpenCode inside the workstation image as a throwaway agent
# sandbox. The container:
#
#   * runs as YOUR uid/gid, so files the agent writes are owned by you, not root
#   * mounts ONLY the current directory (as /work) -- nothing else
#   * gets no access to ~/.aws, ~/.kube, ~/.ssh, ~/.gnupg, or any other host dir,
#     and no Docker socket
#
# so the agent has the full DevOps toolset but none of your credentials and can
# only touch the project you launch it in.
#
# Usage:
#   ./sandbox.sh                  # Claude Code (default)
#   ./sandbox.sh opencode         # OpenCode
#   ./sandbox.sh claude --resume  # extra args pass through to the agent
#
# Env knobs:
#   WORKSTATION_IMAGE  image to run            (default: workstation)
#   DOCKER             docker invocation       (default: "sudo docker"; set to
#                                               "docker" for rootless / docker group)
#   ANTHROPIC_API_KEY  if set, forwarded into the container (as an env var, not a
#                      mounted file) so Claude Code is authenticated non-interactively
set -euo pipefail

# First positional arg is the agent to run; the rest pass through to it.
AGENT="${1:-claude}"
shift || true

IMAGE="${WORKSTATION_IMAGE:-workstation}"
DOCKER="${DOCKER:-sudo docker}"

# Keep all agent state (auth, config, history) under one gitignorable directory
# inside the project, rather than scattering dotfiles in the repo root or losing
# it every run to --rm. It is created on the host so it is owned by you and the
# non-root container user can write to it.
HOME_DIR=".sandbox-home"
mkdir -p "${HOME_DIR}"

exec ${DOCKER} run --rm -it \
  --user "$(id -u):$(id -g)" \
  --security-opt no-new-privileges \
  -v "${PWD}:/work" \
  -w /work \
  -e HOME="/work/${HOME_DIR}" \
  -e USER="$(id -un)" \
  ${ANTHROPIC_API_KEY:+-e ANTHROPIC_API_KEY} \
  "${IMAGE}" \
  "${AGENT}" "$@"
