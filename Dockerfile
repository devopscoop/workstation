FROM alpine:3.10.2

# Get latest version numbers by running update.sh script in this directory.
ENV AWS_IAM_AUTHENTICATOR_VERSION=0.4.0
ENV HELM_DIFF_VERSION=v2.11.0+5
ENV HELM_GIT_VERSION=v0.4.2
ENV HELM_PUSH_VERSION=v0.7.1
ENV HELMFILE_VERSION=v0.81.0
ENV HELM_VERSION=v2.14.3
ENV KUBECTL_VERSION=v1.15.3
ENV TERRAFORM_VERSION=0.12.6
ENV VERT_VERSION=v0.1.0
ENV YAMALE_VERSION=2.0
ENV YAML_LINT_VERSION=1.17.0
ENV YQ_VERSION=2.7.2

# Adding this to fix this message during pip3 upgrade:
# The scripts pyrsa-decrypt, pyrsa-decrypt-bigfile, pyrsa-encrypt,
# pyrsa-encrypt-bigfile, pyrsa-keygen, pyrsa-priv2pub, pyrsa-sign and
# pyrsa-verify are installed in '/root/.local/bin' which is not on PATH.
# Consider adding this directory to PATH or, if you prefer to suppress this
# warning, use --no-warn-script-location.
ENV PATH "/root/.local/bin:${PATH}"

RUN apk --no-cache add bash ca-certificates curl gettext git groff jq openssh-client python3 vim

# Adding this to fix this message during pip3 install:
# You are using pip version 19.0.3, however version 19.1.1 is available. You
# should consider upgrading via the 'pip install --upgrade pip' command.
RUN pip3 install --no-cache-dir --upgrade pip

RUN pip3 install --no-cache-dir awscli "yamale==$YAMALE_VERSION" "yamllint==$YAML_LINT_VERSION" "yq==$YQ_VERSION"

WORKDIR /usr/local/bin

RUN curl -L -o aws-iam-authenticator "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64" && chmod +x aws-iam-authenticator
RUN curl -sL https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_Linux_amd64.tar.gz | tar -xz && chmod +x eksctl
RUN curl -L -o helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64" && chmod +x helmfile
RUN curl -s "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xz && mv linux-amd64/helm . && mv linux-amd64/tiller . && rm -rf linux-amd64
RUN curl -O "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && chmod +x kubectl
RUN curl -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && unzip /tmp/terraform.zip && chmod +x /usr/local/bin/terraform && rm /tmp/terraform.zip
RUN curl -L -o vert "https://github.com/Masterminds/vert/releases/download/${VERT_VERSION}/vert-${VERT_VERSION}-linux-amd64" && chmod +x vert

WORKDIR /root

RUN helm init --client-only
RUN helm plugin install https://github.com/aslafy-z/helm-git --version "${HELM_GIT_VERSION}"
RUN helm plugin install https://github.com/chartmuseum/helm-push --version "${HELM_PUSH_VERSION}"
RUN helm plugin install https://github.com/databus23/helm-diff --version "${HELM_DIFF_VERSION}"

COPY .bashrc .
