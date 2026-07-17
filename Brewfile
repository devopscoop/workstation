# Brewfile for workstation
#
# Installs every CLI tool used or referenced by this repo.
# Usage: brew bundle
#
# Note: the ~25 DevOps tools (kubectl, helm, flux, opentofu, aws/az/gcloud,
# etc.) are installed INSIDE the image by the Dockerfile and run in the
# container — they are not local dependencies. Building and running the image
# only needs the tools below.

# Docker Desktop - `docker build` / `docker run` for the image; sandbox.sh
# drives it too. (Alternative: `brew install docker colima` for a desktop-free setup.)
cask "docker-desktop"

# bash - update.sh and sandbox.sh use bash with bashisms
brew "bash"

# curl - update.sh resolves each tool's latest release version
brew "curl"

# git - fork/clone/update workflow in the README
brew "git"
