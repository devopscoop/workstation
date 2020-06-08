FROM alpine:3.12.0

# Adding Cloud Service Provider (CSP) argument to build separate images for AWS and GCP.
ARG CSP

# These version numbers were automatically generated with the update.sh script.
ENV AWS_IAM_AUTHENTICATOR_VERSION=0.5.0
ENV EKSCTL_VERSION=0.21.0
ENV FLUXCTL_VERSION=1.19.0
ENV GOOGLE_CLOUD_SDK_VERSION=290.0.0
ENV HELM2_VERSION=v2.16.7
ENV HELM3_VERSION=v3.2.3
ENV HELMFILE_VERSION=v0.118.6
ENV HELM_2TO3_VERSION=v0.5.1
ENV HELM_DIFF_VERSION=v3.1.1
ENV HELM_GIT_VERSION=v0.7.0
ENV HELM_PUSH_VERSION=v0.8.1
ENV HELM_SECRETS_VERSION=v2.0.2
ENV ISTIOCTL_VERSION=1.6.1
ENV K9S_VERSION=v0.20.5
ENV KUBECTL_VERSION=v1.18.3
ENV SKAFFOLD_VERSION=v1.10.1
ENV SOPS_VERSION=v3.5.0
ENV TF_SOPS_VERSION=0.5.1
ENV YQ_VERSION=3.3.0

RUN apk --no-cache add bash bash-completion ca-certificates curl gettext git gnupg groff jq openssh-client openssl terraform vim

RUN if [[ "${CSP}" = "aws" ]]; then apk --no-cache add aws-cli; fi

WORKDIR /usr/local/bin

RUN if [[ "${CSP}" = "aws" ]]; then curl -sL -o aws-iam-authenticator "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64" && chmod +x aws-iam-authenticator && curl -sL "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_$(uname -s)_amd64.tar.gz" | tar -xz && chmod +x eksctl; fi
RUN curl -sL -o fluxctl "https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_amd64" && chmod +x fluxctl
RUN curl -sL "https://get.helm.sh/helm-${HELM2_VERSION}-linux-amd64.tar.gz" | tar -xz && mv linux-amd64/helm ./helm && mv linux-amd64/tiller . && rm -rf linux-amd64
RUN curl -sL "https://get.helm.sh/helm-${HELM3_VERSION}-linux-amd64.tar.gz" | tar -xz && mv linux-amd64/helm ./helm3 && rm -rf linux-amd64
RUN curl -sL -o helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64" && chmod +x helmfile
RUN curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz" | tar -xz
RUN curl -sL -O "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && chmod +x kubectl
RUN curl -sL -o skaffold "https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-amd64" && chmod +x skaffold
RUN curl -sL -o sops "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux" && chmod +x sops
RUN curl -sL -o yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" && chmod +x yq
RUN curl -sL "https://github.com/istio/istio/releases/download/${ISTIOCTL_VERSION}/istioctl-${ISTIOCTL_VERSION}-linux-amd64.tar.gz" | tar -xz

WORKDIR /root/.terraform.d/plugins/linux_amd64

RUN curl -sL -o /tmp/tf_sops.zip "https://github.com/carlpett/terraform-provider-sops/releases/download/v${TF_SOPS_VERSION}/terraform-provider-sops_${TF_SOPS_VERSION}_linux_amd64.zip" && unzip /tmp/tf_sops.zip && rm /tmp/tf_sops.zip

WORKDIR /root

RUN if [[ "${CSP}" = "gcp" ]]; then curl -sL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" | tar -xz; fi

# Helm 2
RUN helm init --client-only
RUN helm plugin install https://github.com/aslafy-z/helm-git --version "${HELM_GIT_VERSION}"
RUN helm plugin install https://github.com/chartmuseum/helm-push --version "${HELM_PUSH_VERSION}"
RUN helm plugin install https://github.com/databus23/helm-diff --version "${HELM_DIFF_VERSION}"
RUN helm plugin install https://github.com/zendesk/helm-secrets --version "${HELM_SECRETS_VERSION}"

# Helm 3
RUN helm3 plugin install https://github.com/aslafy-z/helm-git --version "${HELM_GIT_VERSION}"
RUN helm3 plugin install https://github.com/chartmuseum/helm-push --version "${HELM_PUSH_VERSION}"
RUN helm3 plugin install https://github.com/databus23/helm-diff --version "${HELM_DIFF_VERSION}"
RUN helm3 plugin install https://github.com/helm/helm-2to3 --version "${HELM_2TO3_VERSION}"
RUN helm3 plugin install https://github.com/zendesk/helm-secrets --version "${HELM_SECRETS_VERSION}"

COPY .profile .

# Behavior changed between Alpine 3.10.3 and 3.11.2, and the image was no
# longer running .profile. Not sure why. This is a totally legit hack...
RUN ln -s .profile .bashrc
RUN ln -s .profile .bash_profile

RUN rm -rf /tmp/*
