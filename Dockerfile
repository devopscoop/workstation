FROM alpine:3.10.2

# These version numbers were automatically generated with the update.sh script.
ENV AWS_IAM_AUTHENTICATOR_VERSION=0.4.0
ENV FLUXCTL_VERSION=1.15.0
ENV HELMFILE_VERSION=v0.87.0
ENV HELM_DIFF_VERSION=v2.11.0+5
ENV HELM_GIT_VERSION=v0.4.2
ENV HELM_PUSH_VERSION=v0.7.1
ENV HELM_SECRETS_VERSION=v2.0.2
ENV HELM_VERSION=v2.14.3
ENV HELM3_VERSION=v3.0.0-beta.4
ENV K9S_VERSION=0.9.1
ENV KUBECTL_VERSION=v1.16.2
ENV SOPS_VERSION=3.4.0
ENV TERRAFORM_VERSION=0.12.10
ENV VERT_VERSION=v0.1.0
ENV YAMALE_VERSION=2.0.1
ENV YAML_LINT_VERSION=1.18.0
ENV YQ_VERSION=2.7.2

# Adding this to fix this message during pip3 upgrade:
# The scripts pyrsa-decrypt, pyrsa-decrypt-bigfile, pyrsa-encrypt,
# pyrsa-encrypt-bigfile, pyrsa-keygen, pyrsa-priv2pub, pyrsa-sign and
# pyrsa-verify are installed in '/root/.local/bin' which is not on PATH.
# Consider adding this directory to PATH or, if you prefer to suppress this
# warning, use --no-warn-script-location.
ENV PATH "/root/.local/bin:${PATH}"

RUN apk --no-cache add bash ca-certificates curl gettext git gnupg groff jq openssh-client python3 vim

# Adding this to fix this message during pip3 install:
# You are using pip version 19.0.3, however version 19.1.1 is available. You
# should consider upgrading via the 'pip install --upgrade pip' command.
RUN pip3 install --no-cache-dir --upgrade pip

RUN pip3 install --no-cache-dir awscli "yamale==$YAMALE_VERSION" "yamllint==$YAML_LINT_VERSION" "yq==$YQ_VERSION"

WORKDIR /usr/local/bin

RUN curl -L -o aws-iam-authenticator "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64" && chmod +x aws-iam-authenticator
RUN curl -sL https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_Linux_amd64.tar.gz | tar -xz && chmod +x eksctl
RUN curl -sL -o fluxctl "https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_amd64" && chmod +x fluxctl
RUN curl -s "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xz && mv linux-amd64/helm . && mv linux-amd64/tiller . && rm -rf linux-amd64
RUN curl -s "https://get.helm.sh/helm-${HELM3_VERSION}-linux-amd64.tar.gz" | tar -xz && mv linux-amd64/helm ./helm3 && rm -rf linux-amd64
RUN curl -L -o helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64" && chmod +x helmfile
RUN curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_${K9S_VERSION}_Linux_x86_64.tar.gz" | tar -xz
RUN curl -O "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && chmod +x kubectl
RUN curl -L -o sops "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux" && chmod +x sops
RUN curl -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && unzip /tmp/terraform.zip && chmod +x /usr/local/bin/terraform && rm /tmp/terraform.zip
RUN curl -L -o vert "https://github.com/Masterminds/vert/releases/download/${VERT_VERSION}/vert-${VERT_VERSION}-linux-amd64" && chmod +x vert

WORKDIR /root

RUN helm init --client-only
RUN helm plugin install https://github.com/aslafy-z/helm-git --version "${HELM_GIT_VERSION}"
RUN helm plugin install https://github.com/chartmuseum/helm-push --version "${HELM_PUSH_VERSION}"
RUN helm plugin install https://github.com/databus23/helm-diff --version "${HELM_DIFF_VERSION}"
RUN helm plugin install https://github.com/futuresimple/helm-secrets --version "${HELM_SECRETS_VERSION}"

COPY .bashrc .
