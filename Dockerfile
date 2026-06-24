FROM ubuntu:26.04

SHELL ["/bin/bash", "-c"]

# Adding Cloud Service Provider (CSP) argument to build separate images for AWS and GCP.
ARG CSP

# ========== Pasted output from update.sh below ==========

# AWS doesn't know how to release things to GitHub properly, you'll have to
# manually find the latest tag here: https://github.com/aws/aws-cli/tags
ENV AWS_CLI_VERSION=2.35.11

ENV DYFF_VERSION=1.12.0
ENV EKSCTL_VERSION=v0.227.0
ENV FLUXCD_VERSION=2.8.8
ENV GOOGLE_CLOUD_SDK_VERSION=
ENV HELM_VERSION=v4.2.2
ENV HELMFILE_VERSION=v1.6.0
ENV HELM_DIFF_VERSION=v3.15.10
ENV HELM_GIT_VERSION=v1.5.2
ENV HELM_SECRETS_VERSION=v4.7.7
ENV ISTIOCTL_VERSION=1.30.1
ENV KUBECTL_VERSION=v1.31.0
ENV KUBENT_VERSION=0.7.3

# Kustomize has multiple products in a single repo, so the "latest" release
# cannot be trusted. You'll have to manually look up the version here:
# https://github.com/kubernetes-sigs/kustomize/releases
ENV KUSTOMIZE_VERSION=v5.8.1

ENV SKAFFOLD_VERSION=v2.22.0
ENV SOPS_VERSION=v3.13.1
ENV OPENTOFU_VERSION=1.12.3
ENV TFLINT_VERSION=v0.63.1
ENV TFSEC_VERSION=v1.28.14
ENV TF_SOPS_VERSION=1.4.1
ENV TRIVY_VERSION=0.71.2
ENV YQ_VERSION=v4.53.3
ENV CLAUDE_CODE_VERSION=2.1.187
ENV OPENCODE_VERSION=v1.17.9

# ========== Pasted output from update.sh above ==========

RUN apt update
RUN apt install -y bash-completion ca-certificates curl gettext git gnupg groff jq unzip wget python3-pip

# Install Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
RUN apt-get install -y ca-certificates curl gnupg lsb-release
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

WORKDIR /usr/local/bin

RUN curl -sL "https://github.com/homeport/dyff/releases/download/v${DYFF_VERSION}/dyff_${DYFF_VERSION}_linux_amd64.tar.gz" | tar -xz dyff
RUN curl -sL "https://github.com/fluxcd/flux2/releases/download/v${FLUXCD_VERSION}/flux_${FLUXCD_VERSION}_linux_amd64.tar.gz" | tar -xz flux && chmod +x flux
RUN curl -sL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xz && mv linux-amd64/helm ./helm && rm -rf linux-amd64
RUN curl -sL -o helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64" && chmod +x helmfile
RUN curl -sL "https://github.com/istio/istio/releases/download/${ISTIOCTL_VERSION}/istioctl-${ISTIOCTL_VERSION}-linux-amd64.tar.gz" | tar -xz
RUN curl -sL -O "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && chmod +x kubectl
RUN curl -sL "https://github.com/doitintl/kube-no-trouble/releases/download/${KUBENT_VERSION}/kubent-${KUBENT_VERSION}-linux-amd64.tar.gz" | tar -xz
RUN curl -sL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" | tar -xz
RUN curl -sL -o skaffold "https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-amd64" && chmod +x skaffold
RUN curl -sL -o sops "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux" && chmod +x sops
RUN curl -sL "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_amd64.tar.gz" | tar -xz tofu
RUN curl -sL -o /tmp/tflint.zip "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip" && unzip -q /tmp/tflint.zip && rm /tmp/tflint.zip
RUN curl -sL -o tfsec "https://github.com/tfsec/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64" && chmod +x tfsec
RUN curl -sL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" | tar -xz trivy
RUN curl -sL -o yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" && chmod +x yq
RUN curl -sL "https://github.com/anomalyco/opencode/releases/download/${OPENCODE_VERSION}/opencode-linux-x64.tar.gz" | tar -xz opencode && chmod +x opencode

WORKDIR /root/.terraform.d/plugins/linux_amd64

RUN curl -sL -o /tmp/tf_sops.zip "https://github.com/carlpett/terraform-provider-sops/releases/download/v${TF_SOPS_VERSION}/terraform-provider-sops_${TF_SOPS_VERSION}_linux_amd64.zip" && unzip -q /tmp/tf_sops.zip && rm /tmp/tf_sops.zip

WORKDIR /root

# Helm plugins
# Helm 4 made `helm plugin install --verify` default to true; these community
# plugins ship no signatures, so installs fail with "plugin source does not
# support verification" unless we opt out with --verify=false.
RUN helm plugin install https://github.com/databus23/helm-diff --version "${HELM_DIFF_VERSION}" --verify=false
RUN helm plugin install https://github.com/aslafy-z/helm-git --version "${HELM_GIT_VERSION}" --verify=false
RUN helm plugin install https://github.com/jkroepke/helm-secrets --version "${HELM_SECRETS_VERSION}" --verify=false

# Trivy templates
RUN curl -sL -o gitlab.tpl "https://raw.githubusercontent.com/aquasecurity/trivy/v${TRIVY_VERSION}/contrib/gitlab.tpl"

# Claude Code
# The official installer drops the `claude` launcher in ~/.local/bin, so symlink
# it into /usr/local/bin to match where every other tool lands on PATH.
RUN curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_CODE_VERSION}" \
    && ln -sf /root/.local/bin/claude /usr/local/bin/claude

COPY .profile .

# Behavior changed between Alpine 3.10.3 and 3.11.2, and the image was no
# longer running .profile. Not sure why. This is a totally legit hack...
RUN ln -s .profile .bash_profile

# Moving CSP-specific parts to the bottom so most layers are shared.

# AWS specific section
# It got big enough to need it's own script. This is probably an anti-pattern...
COPY aws.sh /tmp/
RUN if [[ "${CSP}" = "aws" ]]; then /tmp/aws.sh; fi

# Azure specific section
COPY azure.sh /tmp/
RUN if [[ "${CSP}" = "azure" ]]; then /tmp/azure.sh; fi

# GCP specific section
RUN if [[ "${CSP}" = "gcp" ]]; then curl -sL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" | tar -xz; fi

# Minor cleanup
RUN rm -rvf /tmp/*

# Ensuring that final WORKDIR is /root
WORKDIR /root
