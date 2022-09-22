
#!/bin/bash

set -x

# Set working directory
cd /root

# See https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
# We don't use sudo, because we are already running as root.
./aws/install

# Set new working directory for the following tools
cd /usr/local/bin

curl -sL -o aws-iam-authenticator "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64"
chmod +x aws-iam-authenticator

curl -sL "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_$(uname -s)_amd64.tar.gz" | tar -xz
chmod +x eksctl
