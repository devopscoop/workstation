#!/bin/bash

# This dumps out the latest versions of all the applications that are in this
# Docker image. You can copy and paste the output into the Dockerfile to update
# everything.

echo "ENV AWS_IAM_AUTHENTICATOR_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/latest) | sed 's/^v//')"
echo "ENV HELMFILE_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/roboll/helmfile/releases/latest))"
echo "ENV HELM_DIFF_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/databus23/helm-diff/releases/latest))"
echo "ENV HELM_GIT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aslafy-z/helm-git/releases/latest))"
echo "ENV HELM_PUSH_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/chartmuseum/helm-push/releases/latest))"
echo "ENV HELM_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/helm/helm/releases/latest))"
echo "ENV KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
echo "ENV TERRAFORM_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/hashicorp/terraform/releases/latest) | sed 's/^v//')"
echo "ENV VERT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/Masterminds/vert/releases/latest))"
echo "ENV YAMALE_VERSION=$(pip3 search yamale | grep '^yamale ' | sed -E 's/.*\((.+)\).*/\1/')"
echo "ENV YAML_LINT_VERSION=$(pip3 search yamllint | grep '^yamllint ' | sed -E 's/.*\((.+)\).*/\1/')"
echo "ENV YQ_VERSION=$(pip3 search yq | grep '^yq ' | sed -E 's/.*\((.+)\).*/\1/')"
