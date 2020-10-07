#!/bin/bash

PATH='/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'

function usage {
  cat <<EOF

DeDevSecOps Admin Script

$(basename $0) provides a common environment and set of tools for people and
CI/CD processes that work with Kubernetes clusters.

Usage:

  ./$(basename $0) [-c command] [-h] [-i image] [-n namespace] [-p port]

  -c  Command: runs a command non-interactively inside the container.

  -h  Help

  -i  Image. Default: registry.gitlab.com/dedevsecops/workstation:latest

  -n  Namespace: sets the Kubernetes namespace.

  -p  Port: exposes the container's port (or range of ports) to the host.

Examples:

  Run interactively:
  ./$(basename $0)

  Run non-interactively by putting a command in '' or $'', for example:
  ./$(basename $0) -c $'kubectl get pods -o json | jq \'.items[].spec.containers[]\''

  Run a specific image:
  ./$(basename $0) -i registry.gitlab.com/dedevsecops/workstation:deadbeef

  Expose PostgreSQL port so you can connect to a database from your local computer:
  ./$(basename $0) -p 5432

EOF
exit 1
}

while getopts :c:hi:n:p: option; do
    case $option in
        c) user_cmd="-c -- \"${OPTARG}\"";; # Weird quoting needed because I don't know. It works.
        h) usage;;
        i) WORKSTATION_IMAGE="${OPTARG}";;
        n) NAMESPACE="${OPTARG}";;
        p) ports="-p ${OPTARG}:${OPTARG}";;
        \?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

if [[ -z $WORKSTATION_IMAGE ]]; then
  export WORKSTATION_IMAGE='registry.gitlab.com/dedevsecops/workstation:latest'
fi

docker pull -q $WORKSTATION_IMAGE 1>/dev/null

# .gnupg has to be rw for some reason... should look into why and try to make it ro.
eval docker run \
  ${ports} \
  --rm \
  -e EDITOR \
  -e NAMESPACE="${NAMESPACE}" \
  -e WORKSTATION_IMAGE \
  -it \
  -v "${HISTFILE}":/root/.bash_history:rw \
  -v "${HOME}/.aws":/root/.aws:ro \
  -v "${HOME}/.gitconfig":/root/.gitconfig:ro \
  -v "${HOME}/.gnupg":/root/.gnupg:rw \
  -v "${HOME}/.kube":/root/.kube:ro \
  -v "${HOME}/.ssh":/root/.ssh:ro \
  -v "${HOME}/.vimrc":/root/.vimrc:ro \
  -v "${PWD}":/mnt \
  "${WORKSTATION_IMAGE}" \
  bash --login ${user_cmd}

# I keep hoping that one day we will discover the magic that allows us to run
# this as the caller's UID and GID, but I still haven't figured it out. This is
# a hint.
#  -u $(id -u):$(id -g) \
#  -v "${HOME}/.aws":"/home/${USER}/.aws":ro \
#  -v "${HOME}/.gitconfig":"/home/${USER}/.gitconfig":ro \
#  -v "${HOME}/.gnupg":"/home/${USER}/.gnupg":rw \
#  -v "${HOME}/.ssh":"/home/${USER}/.ssh":ro \
#  -v /etc/group:/etc/group:ro \
#  -v /etc/passwd:/etc/passwd:ro \
#  -v /etc/shadow:/etc/shadow:ro \
#  -w "/home/${USER}" \
