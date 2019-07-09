#!/bin/bash

echo "ENV AWS_IAM_AUTHENTICATOR_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/latest) | sed 's/^v//')"
echo "ENV HELMFILE_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/roboll/helmfile/releases/latest))"
echo "ENV HELM_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/helm/helm/releases/latest))"
echo "ENV KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
echo "ENV TERRAFORM_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/hashicorp/terraform/releases/latest) | sed 's/^v//')"
echo "ENV VERT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/Masterminds/vert/releases/latest))"
echo "ENV YAMALE_VERSION=$(pip3 search yamale | grep '^yamale ' | sed -E 's/.*\((.+)\).*/\1/')"
echo "ENV YAML_LINT_VERSION=$(pip3 search yamllint | grep '^yamllint ' | sed -E 's/.*\((.+)\).*/\1/')"
echo "ENV YQ_VERSION=$(pip3 search yq | grep '^yq ' | sed -E 's/.*\((.+)\).*/\1/')"
