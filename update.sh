#!/bin/bash

# This dumps out the latest versions of all the applications that are in this
# Docker image. You can copy and paste the output into the Dockerfile to update
# everything.

cat <<EOF
# ========== Pasted output from update.sh below ==========

# AWS doesn't know how to release things to GitHub properly, you'll have to
# manually find the latest tag here: https://github.com/aws/aws-cli/tags
ENV AWS_CLI_VERSION=2.26.1

ENV DYFF_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/homeport/dyff/releases/latest) | sed 's/^v//')
ENV EKSCTL_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/eksctl-io/eksctl/releases/latest))
ENV FLUXCD_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/fluxcd/flux2/releases/latest) | sed 's/^v//')
ENV GOOGLE_CLOUD_SDK_VERSION=$(curl -s https://cloud.google.com/sdk/docs/install-sdk | grep -oE '"Installing the latest gcloud CLI version \([0-9.]+\)"' | sed -E 's/.*\((.*)\).*/\1/')
ENV HELM_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/helm/helm/releases/latest))
ENV HELMFILE_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/helmfile/helmfile/releases/latest))
ENV HELM_DIFF_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/databus23/helm-diff/releases/latest))
ENV HELM_GIT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aslafy-z/helm-git/releases/latest))
ENV HELM_SECRETS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/jkroepke/helm-secrets/releases/latest))
ENV ISTIOCTL_VERSION=$(curl -sL https://github.com/istio/istio/releases | grep -o 'releases/[0-9]*.[0-9]*.[0-9]*/' | sort --version-sort | tail -1 | awk -F'/' '{ print $2}')
ENV KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
ENV KUBENT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/doitintl/kube-no-trouble/releases/latest))

# Kustomize has multiple products in a single repo, so the "latest" release
# cannot be trusted. You'll have to manually look up the version here:
# https://github.com/kubernetes-sigs/kustomize/releases
ENV KUSTOMIZE_VERSION=v5.6.0

ENV SKAFFOLD_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/GoogleContainerTools/skaffold/releases/latest))
ENV SOPS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/getsops/sops/releases/latest))
ENV OPENTOFU_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/opentofu/opentofu/releases/latest) | sed 's/^v//')
ENV TFLINT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/terraform-linters/tflint/releases/latest))
ENV TFSEC_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aquasecurity/tfsec/releases/latest))
ENV TF_SOPS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/carlpett/terraform-provider-sops/releases/latest) | sed 's/^v//')
ENV TRIVY_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aquasecurity/trivy/releases/latest) | sed 's/^v//')
ENV YQ_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/mikefarah/yq/releases/latest))

# ========== Pasted output from update.sh above ==========

EOF
