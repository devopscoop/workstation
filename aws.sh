#!/bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

# Map Docker's TARGETARCH (amd64/arm64; default amd64 for classic builders) to
# each tool's naming convention. The AWS CLI uses uname-style x86_64/aarch64.
ARCH="${TARGETARCH:-amd64}"
case "${ARCH}" in
    amd64) AWSCLI_ARCH=x86_64 ;;
    arm64) AWSCLI_ARCH=aarch64 ;;
    *) echo "unsupported TARGETARCH: ${ARCH}" >&2; exit 1 ;;
esac

# Set working directory
cd /root

# See https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${AWSCLI_ARCH}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
# We don't use sudo, because we are already running as root.
./aws/install

# Set new working directory for the following tools
cd /usr/local/bin

curl -sL -o aws-iam-authenticator "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_${ARCH}"
chmod +x aws-iam-authenticator

curl -sL "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_$(uname -s)_${ARCH}.tar.gz" | tar -xz
chmod +x eksctl
