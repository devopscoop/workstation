#!/bin/bash

if [[ $# -gt 0 ]]; then
  cat <<EOF

DeDevSecOps Workstation

https://gitlab.com/dedevsecops/workstation

This script runs the Docker image interacively so multiple people managing
multiple Kubernetes clusters can administer the clusters using the correct
versions of all tools for that particular cluster.

To use this script, you need to copy admin.sh and env.sh to a Kubernetes
cluster repo similar to the one described here:

https://gitlab.com/dedevsecops/k8s-eks-template

After you copy env.sh, customize it for your environment.

EOF
fi

export this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${this_dir}/env.sh"
WORKSTATION_VERSION=
docker run \
  -it \
  --rm \
  -v "${this_dir}":/mnt \
  -v "${HOME}/.aws":/root/.aws \
  -v "${HOME}/.ssh":/root/.ssh \
  "registry.gitlab.com/dedevsecops/workstation:${WORKSTATION_VERSION}" \
  bash
