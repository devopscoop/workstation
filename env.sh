#!/bin/bash
export AWS_DEFAULT_REGION='us-east-2'
export AWS_PROFILE='dedevsecops'
export CLUSTER_NAME=tenant-dev
export DOMAIN_NAME=dedevsecops.com
export GITLAB_ORG=dedevsecops

# If you're creating a new Kubernetes cluster, set WORKSTATION_VERSION to the
# most recent hash from:
#
#  https://gitlab.com/dedevsecops/workstation/container_registry
#
# This will ensure that everyone working on this cluster will be using the same
# versions of kubectl, helm, etc.
#
# DO NOT USE "latest"!
export WORKSTATION_VERSION=021cb63b
