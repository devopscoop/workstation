#!/bin/bash

# This dumps out the latest versions of all the applications that are in this
# Docker image. You can copy and paste the output into the Dockerfile to update
# everything.

cat <<EOF
# ========== Pasted output from update.sh below ==========

# AWS doesn't know how to release things to GitHub properly, you'll have to
# manually find the latest tag here: https://github.com/aws/aws-cli/tags
ENV AWS_CLI_VERSION=2.9.16

# aws-iam-authenticator is deprecated, but we still use it in some places. See:
# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
ENV AWS_IAM_AUTHENTICATOR_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/latest) | sed 's/^v//')

ENV DYFF_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/homeport/dyff/releases/latest) | sed 's/^v//')
ENV EKSCTL_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/weaveworks/eksctl/releases/latest))
ENV FLUXCD_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/fluxcd/flux2/releases/latest) | sed 's/^v//')
ENV FLUXCTL_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/fluxcd/flux/releases/latest))
ENV GOOGLE_CLOUD_SDK_VERSION=$(curl -Ls https://cloud.google.com/sdk/docs/quickstart | grep -oE 'google-cloud-cli-[0-9]+\.[0-9]+\.[0-9]+-linux-x86_64.tar.gz' | grep -oE '[0-9]+\.[0-9]+\.[0-9]' | tail -n1)
ENV HELM3_VERSION=$(curl -s https://github.com/helm/helm/releases | grep -oE '/helm/helm/releases/tag/v[^"]*' | grep -oE 'v3[^"]*' | head -n 1)
ENV HELMFILE_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/roboll/helmfile/releases/latest))
ENV HELM_DIFF_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/databus23/helm-diff/releases/latest))
ENV HELM_GIT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aslafy-z/helm-git/releases/latest))
ENV HELM_SECRETS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/zendesk/helm-secrets/releases/latest))
ENV ISTIOCTL_VERSION=$(curl -sL https://github.com/istio/istio/releases | grep -o 'releases/[0-9]*.[0-9]*.[0-9]*/' | sort --version-sort | tail -1 | awk -F'/' '{ print $2}')
ENV K9S_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/derailed/k9s/releases/latest))
ENV KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
ENV KUBENT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/doitintl/kube-no-trouble/releases/latest))
ENV KUBEVAL_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/instrumenta/kubeval/releases/latest))

# Kustomize has multiple products in a single repo, so the "latest" release
# cannot be trusted. You'll have to manually look up the version here:
# https://github.com/kubernetes-sigs/kustomize/releases
ENV KUSTOMIZE_VERSION=v4.5.7

ENV SKAFFOLD_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/GoogleContainerTools/skaffold/releases/latest))
ENV SOPS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/mozilla/sops/releases/latest))
ENV STERN_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/stern/stern/releases/latest) | sed 's/^v//')
ENV TERRAFORM_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/hashicorp/terraform/releases/latest) | sed 's/^v//')
ENV TFENV_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/tfutils/tfenv/releases/latest) | sed 's/^v//')
ENV TFLINT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/terraform-linters/tflint/releases/latest))
ENV TFSEC_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aquasecurity/tfsec/releases/latest))
ENV TF_SOPS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/carlpett/terraform-provider-sops/releases/latest) | sed 's/^v//')
ENV TRIVY_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aquasecurity/trivy/releases/latest) | sed 's/^v//')

# We have both yq v3 and v4 in this image. This is hardcoded to the last v3 version of yq, which we still use.
ENV YQ3_VERSION=3.4.1
# ...and this is the v4 version.
ENV YQ4_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/mikefarah/yq/releases/latest))

# ========== Pasted output from update.sh above ==========

EOF
