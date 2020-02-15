#!/bin/bash

PATH='/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'

function usage {
  cat <<EOF

DeDevSecOps Workstation

https://gitlab.com/dedevsecops/workstation

$(basename $0) runs the Docker image interacively so multiple people managing
multiple Kubernetes clusters can administer the clusters using the correct
versions of all tools for that particular cluster.

To use this script, you need to copy admin.sh and env.sh to a Kubernetes
cluster repo similar to the one described here:

https://gitlab.com/dedevsecops/k8s-eks-template

After you copy env.sh, customize it for your environment.

Usage:

  ./$(basename $0) [-c command] [-h] [-p port]

  -c  Runs a command non-interactively inside the container.
  -h  Help
  -p  Exposes the container's port (or range of ports) to the host.

Examples:

  Run interactively:
  ./$(basename $0)

  Run non-interactively by putting a command in '' or $'', for example:
  ./$(basename $0) -c $'kubectl get pods -o json | jq \'.items[].spec.containers[]\''

  Expose PostgreSQL port so you can connect to a database from your local computer:
  ./$(basename $0) -p 5432

EOF
exit 1
}

while getopts :c:p:h option; do
    case $option in
        c) user_cmd="-c -- \"${OPTARG}\"";; # Weird quoting needed because I don't know. It works.
        p) ports="-p ${OPTARG}:${OPTARG}";;
        h) usage;;
        \?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

if [[ "$1" == '-h' || "$1" == '--help' ]]; then
  usage
fi

export this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#export WORKSTATION_IMAGE=$(grep registry.gitlab.com/dedevsecops/workstation "${this_dir}/.gitlab-ci.yml" | cut -d' ' -f 2)
export WORKSTATION_IMAGE=registry.gitlab.com/dedevsecops/workstation:latest

eval docker run \
  --rm \
  -it \
  ${ports} \
  -v "${HOME}/.aws":/root/.aws:ro \
  -v "${HOME}/.gitconfig":/root/.gitconfig:ro \
  -v "${HOME}/.gnupg":/root/.gnupg \
  -v "${HOME}/.ssh":/root/.ssh:ro \
  -v "${HOME}/.vimrc":/root/.vimrc:ro \
  -v "${this_dir}":/mnt \
  ${WORKSTATION_IMAGE} \
  bash --login ${user_cmd}

# We should run as the current user once we ditch "helm init" in the workstation image.
# .gnupg has to be rw for some reason... should look into why and try to make it ro.
#  -u $(id -u):$(id -g) \
#  -v "/etc/group:/etc/group:ro" \
#  -v "/etc/passwd:/etc/passwd:ro" \
#  -v "/etc/shadow:/etc/shadow:ro" \
#  -w "/home/${USER}" \
#  -v "${HOME}/.aws":"/home/${USER}/.aws":ro \
#  -v "${HOME}/.gitconfig":"/home/${USER}/.gitconfig":ro \
#  -v "${HOME}/.gnupg":/home/${USER}/.gnupg \
#  -v "${HOME}/.ssh":"/home/${USER}/.ssh":ro \
