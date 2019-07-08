# I opted to make this Docker image always-up-to-date instead of pinned to
# specific versions of this. This might be a bad idea. Time will tell. 

# sudo docker run -it --name dedevsecops -v dedevsecops:/root dedevsecops bash

FROM alpine:latest

# Installing dependencies
RUN apk --no-cache add \
    bash \
    curl \
    git \
    python3

# Adding this:
ENV PATH "/root/.local/bin:${PATH}"
# To fix this:
# The scripts pyrsa-decrypt, pyrsa-decrypt-bigfile, pyrsa-encrypt,
# pyrsa-encrypt-bigfile, pyrsa-keygen, pyrsa-priv2pub, pyrsa-sign and
# pyrsa-verify are installed in '/root/.local/bin' which is not on PATH.
# Consider adding this directory to PATH or, if you prefer to suppress this
# warning, use --no-warn-script-location.

# Adding this:
RUN pip3 install --upgrade pip
# To fix this:
# You are using pip version 19.0.3, however version 19.1.1 is available. You
# should consider upgrading via the 'pip install --upgrade pip' command.

# AWS CLI
# Based on https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
RUN pip3 install awscli --upgrade --user

# aws-iam-authenticator
# Based on https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
RUN curl -O https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator && \
    curl -O https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator.sha256 && \
    sed -i 's/ /  /g' aws-iam-authenticator.sha256 && \
    sha256sum -c aws-iam-authenticator.sha256 && \
    chmod +x aws-iam-authenticator && \
    mv aws-iam-authenticator /usr/local/bin/

# Helm
# Based on https://helm.sh/docs/using_helm/#installing-helm
# I would use the get_helm.sh script, but it's currently failing with this error:
# SHA sum of /tmp/helm-installer-pHdaFF/helm-v2.14.1-linux-amd64.tar.gz does not match. Aborting.
#RUN curl -L https://git.io/get_helm.sh | bash
RUN helm_release=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/helm/helm/releases/latest)) && \
    curl -O https://get.helm.sh/helm-${helm_release}-linux-amd64.tar.gz && \
    tar -xvf "helm-${helm_release}-linux-amd64.tar.gz" && \
    mv linux-amd64/helm /usr/local/bin/ && \
    mv linux-amd64/tiller /usr/local/bin/ && \
    helm init --client-only && \
    helm plugin install https://github.com/chartmuseum/helm-push && \
    helm plugin install https://github.com/databus23/helm-diff

# helmfile
# Based on https://github.com/roboll/helmfile
RUN helmfile_release=$(basename $(curl -s -o /dev/null -w '%{redirect_url}' https://github.com/roboll/helmfile/releases/latest)) && \
    curl -o helmfile https://github.com/roboll/helmfile/releases/download/${helmfile_release}/helmfile_linux_amd64 && \
    chmod +x helmfile && \
    mv helmfile /usr/local/bin/

# kubectl
# Based on https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux
RUN kubectl_release=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    curl -O "https://storage.googleapis.com/kubernetes-release/release/${kubectl_release}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/
