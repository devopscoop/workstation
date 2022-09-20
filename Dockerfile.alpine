FROM alpine:3.16.2

# Adding Cloud Service Provider (CSP) argument to build separate images for AWS and GCP.
ARG CSP

# ========== Pasted output from update.sh below ==========

# AWS CLI versions newer than 2.1.39 don't work on Alpine Linux. See:
# https://github.com/aws/aws-cli/issues/4685
# Once that issue is resolved, you can find latest versions here:
# https://github.com/aws/aws-cli/tags
ENV AWS_CLI_VERSION=2.1.39

# aws-iam-authenticator is deprecated, but we still use it in some places. See:
# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
ENV AWS_IAM_AUTHENTICATOR_VERSION=0.5.9

ENV DYFF_VERSION=1.5.5
ENV EKSCTL_VERSION=v0.111.0
ENV FLUXCD_VERSION=0.34.0
ENV FLUXCTL_VERSION=1.25.4
ENV GOOGLE_CLOUD_SDK_VERSION=402.0.0
ENV HELM3_VERSION=v3.10.0-rc.1
ENV HELMFILE_VERSION=v0.144.0
ENV HELM_DIFF_VERSION=v3.5.0
ENV HELM_GIT_VERSION=v0.11.2
ENV HELM_SECRETS_VERSION=v2.0.3
ENV ISTIOCTL_VERSION=1.15.0
ENV K9S_VERSION=v0.26.3
ENV KUBECTL_VERSION=v1.25.1
ENV KUBENT_VERSION=0.5.1
ENV KUBEVAL_VERSION=v0.16.1

# Kustomize has multiple products in a single repo, so the "latest" release cannot be trusted.
ENV KUSTOMIZE_VERSION=v4.5.7

ENV SKAFFOLD_VERSION=v1.39.2
ENV SOPS_VERSION=v3.7.3
ENV STERN_VERSION=1.21.0
ENV TERRAFORM_VERSION=1.2.9
ENV TFENV_VERSION=3.0.0
ENV TFLINT_VERSION=v0.40.0
ENV TFSEC_VERSION=v1.27.6
ENV TF_SOPS_VERSION=0.7.1
ENV TRIVY_VERSION=0.32.0

# We have both yq v3 and v4 in this image. This is hardcoded to the last v3 version of yq, which we still use.
ENV YQ3_VERSION=3.4.1
# ...and this is the v4 version.
ENV YQ4_VERSION=v4.27.5

# ========== Pasted output from update.sh above ==========

# Don't install terraform with apk - version is slightly older than current release.
RUN apk --no-cache add bash bash-completion ca-certificates curl docker gettext git gnupg groff jq openssh-client openssl vim

WORKDIR /usr/local/bin

RUN curl -sL "https://github.com/homeport/dyff/releases/download/v${DYFF_VERSION}/dyff_${DYFF_VERSION}_linux_amd64.tar.gz" | tar -xz dyff
RUN curl -sL -o fluxctl "https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_amd64" && chmod +x fluxctl
RUN curl -sL "https://github.com/fluxcd/flux2/releases/download/v${FLUXCD_VERSION}/flux_${FLUXCD_VERSION}_linux_amd64.tar.gz" | tar -xz flux && chmod +x flux

# This creates a symlink to helm called "helm3" for backwards compatibility.
RUN curl -sL "https://get.helm.sh/helm-${HELM3_VERSION}-linux-amd64.tar.gz" | tar -xz && mv linux-amd64/helm ./helm && ln -s helm helm3 && rm -rf linux-amd64

RUN curl -sL -o helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64" && chmod +x helmfile
RUN curl -sL "https://github.com/istio/istio/releases/download/${ISTIOCTL_VERSION}/istioctl-${ISTIOCTL_VERSION}-linux-amd64.tar.gz" | tar -xz
RUN curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz" | tar -xz
RUN curl -sL -O "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && chmod +x kubectl
RUN curl -sL "https://github.com/doitintl/kube-no-trouble/releases/download/${KUBENT_VERSION}/kubent-${KUBENT_VERSION}-linux-amd64.tar.gz" | tar -xz
RUN curl -sL "https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz" | tar -xz kubeval
RUN curl -sL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" | tar -xz
RUN curl -sL -o skaffold "https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-amd64" && chmod +x skaffold
RUN curl -sL -o sops "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux" && chmod +x sops
RUN curl -sL "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz" | tar -xz stern
RUN curl -sL -o /tmp/tfenv.zip "https://github.com/tfutils/tfenv/archive/v${TFENV_VERSION}.zip" && unzip -q /tmp/tfenv.zip && mv "tfenv-${TFENV_VERSION}" "${HOME}/.tfenv" && ln -s ~/.tfenv/bin/* /usr/local/bin && rm /tmp/tfenv.zip
RUN curl -sL -o /tmp/tflint.zip "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip" && unzip -q /tmp/tflint.zip && rm /tmp/tflint.zip
RUN curl -sL -o tfsec "https://github.com/tfsec/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64" && chmod +x tfsec
RUN curl -sL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" | tar -xz trivy
RUN curl -sL -o yq "https://github.com/mikefarah/yq/releases/download/${YQ3_VERSION}/yq_linux_amd64" && chmod +x yq
RUN curl -sL -o yq4 "https://github.com/mikefarah/yq/releases/download/${YQ4_VERSION}/yq_linux_amd64" && chmod +x yq4

# Terraform setup
RUN tfenv install "${TERRAFORM_VERSION}" && tfenv use "${TERRAFORM_VERSION}"

WORKDIR /root/.terraform.d/plugins/linux_amd64

RUN curl -sL -o /tmp/tf_sops.zip "https://github.com/carlpett/terraform-provider-sops/releases/download/v${TF_SOPS_VERSION}/terraform-provider-sops_${TF_SOPS_VERSION}_linux_amd64.zip" && unzip -q /tmp/tf_sops.zip && rm /tmp/tf_sops.zip

WORKDIR /root

# Helm plugins
RUN helm plugin install https://github.com/databus23/helm-diff --version "${HELM_DIFF_VERSION}"
RUN helm plugin install https://github.com/aslafy-z/helm-git --version "${HELM_GIT_VERSION}"
RUN helm plugin install https://github.com/zendesk/helm-secrets --version "${HELM_SECRETS_VERSION}"

# Trivy templates
RUN curl -sL -o gitlab.tpl "https://raw.githubusercontent.com/aquasecurity/trivy/v${TRIVY_VERSION}/contrib/gitlab.tpl"

COPY .profile .

# Behavior changed between Alpine 3.10.3 and 3.11.2, and the image was no
# longer running .profile. Not sure why. This is a totally legit hack...
RUN ln -s .profile .bashrc
RUN ln -s .profile .bash_profile

# Moving CSP-specific parts to the bottom so most layers are shared.

# AWS specific section
# It got big enough to need it's own script. This is probably an anti-pattern...
COPY aws.sh /tmp/
RUN if [[ "${CSP}" = "aws" ]]; then /tmp/aws.sh; fi 

# Azure specific section
RUN if [[ "${CSP}" = "azure" ]]; then apk add --no-cache gcc libffi-dev musl-dev openssl-dev py3-pip py3-pynacl python3-dev && pip install --upgrade pip && pip install azure-cli; fi

# GCP specific section
RUN if [[ "${CSP}" = "gcp" ]]; then curl -sL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" | tar -xz; fi

# Minor cleanup
RUN rm -rvf /tmp/*

# Ensuring that final WORKDIR is /root
WORKDIR /root
