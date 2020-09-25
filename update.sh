#!/bin/bash

# This dumps out the latest versions of all the applications that are in this
# Docker image. You can copy and paste the output into the Dockerfile to update
# everything.

echo '# aws-iam-authenticator is deprecated: https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html'
echo "ENV AWS_IAM_AUTHENTICATOR_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/latest) | sed 's/^v//')"
echo "ENV EKSCTL_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/weaveworks/eksctl/releases/latest))"
echo "ENV DYFF_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/homeport/dyff/releases/latest))"
echo "ENV FLUXCTL_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/fluxcd/flux/releases/latest))"
echo "ENV GOOGLE_CLOUD_SDK_VERSION=$(curl -s https://cloud.google.com/sdk/docs/quickstart | grep -oE 'google-cloud-sdk-[0-9]+\.[0-9]+\.[0-9]+-linux-x86_64.tar.gz' | grep -oE '[0-9]+\.[0-9]+\.[0-9]' | tail -n1)"
echo "ENV HELM3_VERSION=$(curl -s https://github.com/helm/helm/releases | grep -oE '/helm/helm/releases/tag/v[^"]*' | grep -oE 'v3[^"]*' | head -n 1)"
echo "ENV HELMFILE_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/roboll/helmfile/releases/latest))"
echo "ENV HELM_DIFF_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/databus23/helm-diff/releases/latest))"
echo "ENV HELM_GIT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aslafy-z/helm-git/releases/latest))"
echo "ENV HELM_PUSH_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/chartmuseum/helm-push/releases/latest))"
echo "ENV HELM_SECRETS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/zendesk/helm-secrets/releases/latest))"
echo "ENV ISTIOCTL_VERSION=$(curl -sL https://github.com/istio/istio/releases | grep -o 'releases/[0-9]*.[0-9]*.[0-9]*/' | sort --version-sort | tail -1 | awk -F'/' '{ print $2}')"
echo "ENV K9S_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/derailed/k9s/releases/latest))"
echo "ENV KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
echo "ENV SKAFFOLD_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/GoogleContainerTools/skaffold/releases/latest))"
echo "ENV SOPS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/mozilla/sops/releases/latest))"
echo "ENV TERRAFORM_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/hashicorp/terraform/releases/latest) | sed 's/^v//')"
echo "ENV TFLINT_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/terraform-linters/tflint/releases/latest))"
echo "ENV TFSEC_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/liamg/tfsec/releases/latest))"
echo "ENV TF_SOPS_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/carlpett/terraform-provider-sops/releases/latest) | sed 's/^v//')"
echo "ENV TRIVY_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/aquasecurity/trivy/releases/latest) | sed 's/^v//')"
echo "ENV YQ_VERSION=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/mikefarah/yq/releases/latest))"
