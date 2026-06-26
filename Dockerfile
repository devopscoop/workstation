FROM ubuntu:26.04

SHELL ["/bin/bash", "-c"]

# Adding Cloud Service Provider (CSP) argument to build separate images per CSP
# (aws, azure, gcp, digitalocean). Leave unset for the base image.
ARG CSP

# BuildKit auto-populates TARGETARCH (amd64, arm64, …) from --platform. Re-export
# it as an ENV with an amd64 fallback so (a) every arch-specific download below
# can just reference ${TARGETARCH}, (b) the CSP scripts inherit it, and (c)
# classic builders that don't set it (e.g. GitLab's docker build) still work.
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH:-amd64}

# ========== Pasted output from update.sh below ==========

# AWS doesn't know how to release things to GitHub properly, you'll have to
# manually find the latest tag here: https://github.com/aws/aws-cli/tags
ENV AWS_CLI_VERSION=2.35.11

ENV DOCTL_VERSION=1.162.0
ENV DYFF_VERSION=1.12.0
ENV EKSCTL_VERSION=v0.227.0
ENV FLUXCD_VERSION=2.8.8
ENV GOOGLE_CLOUD_SDK_VERSION=574.0.0
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
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/docker.asc https://download.docker.com/linux/ubuntu/gpg && gpg --dearmor -o /etc/apt/keyrings/docker.gpg < /tmp/docker.asc && rm /tmp/docker.asc
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

WORKDIR /usr/local/bin

# Every release is fetched with wget (not curl) for resilience: CDNs stall
# mid-stream from CI runners, and a curl pipe into tar couldn't recover — the
# bytes were gone and -s hid the failure. wget retries the whole transfer
# (--tries), backs off and retries refused connections (--waitretry,
# --retry-connrefused), and aborts a stalled connection at the read timeout
# (--timeout) instead of hanging. Tarballs land in a file first so a retry
# restarts clean; HTTP errors fail the build by default.
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/dyff.tar.gz "https://github.com/homeport/dyff/releases/download/v${DYFF_VERSION}/dyff_${DYFF_VERSION}_linux_${TARGETARCH}.tar.gz" && tar -xzf /tmp/dyff.tar.gz dyff && rm /tmp/dyff.tar.gz
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/flux.tar.gz "https://github.com/fluxcd/flux2/releases/download/v${FLUXCD_VERSION}/flux_${FLUXCD_VERSION}_linux_${TARGETARCH}.tar.gz" && tar -xzf /tmp/flux.tar.gz flux && chmod +x flux && rm /tmp/flux.tar.gz
# get.helm.sh (backed by Azure Front Door) has recurring SSL failures from GitLab's
# runners even over IPv4; the GitHub release mirror is stable.
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/helm.tar.gz "https://github.com/helm/helm/releases/download/${HELM_VERSION}/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" && tar -xzf /tmp/helm.tar.gz "linux-${TARGETARCH}/helm" && mv "linux-${TARGETARCH}/helm" ./helm && rm -rf "linux-${TARGETARCH}" /tmp/helm.tar.gz
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_${TARGETARCH}" && chmod +x helmfile
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/istio.tar.gz "https://github.com/istio/istio/releases/download/${ISTIOCTL_VERSION}/istioctl-${ISTIOCTL_VERSION}-linux-${TARGETARCH}.tar.gz" && tar -xzf /tmp/istio.tar.gz && rm /tmp/istio.tar.gz
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" && chmod +x kubectl
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/kubent.tar.gz "https://github.com/doitintl/kube-no-trouble/releases/download/${KUBENT_VERSION}/kubent-${KUBENT_VERSION}-linux-${TARGETARCH}.tar.gz" && tar -xzf /tmp/kubent.tar.gz && rm /tmp/kubent.tar.gz
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz" && tar -xzf /tmp/kustomize.tar.gz && rm /tmp/kustomize.tar.gz
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O skaffold "https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-${TARGETARCH}" && chmod +x skaffold
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O sops "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${TARGETARCH}" && chmod +x sops
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/tofu.tar.gz "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_${TARGETARCH}.tar.gz" && tar -xzf /tmp/tofu.tar.gz tofu && rm /tmp/tofu.tar.gz
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/tflint.zip "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_${TARGETARCH}.zip" && unzip -q /tmp/tflint.zip && rm /tmp/tflint.zip
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O tfsec "https://github.com/tfsec/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-${TARGETARCH}" && chmod +x tfsec
# Trivy's asset arch tokens are 64bit/ARM64, not Go-style.
RUN ARCH="$([ "${TARGETARCH}" = arm64 ] && echo ARM64 || echo 64bit)" && wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${ARCH}.tar.gz" && tar -xzf /tmp/trivy.tar.gz trivy && rm /tmp/trivy.tar.gz
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}" && chmod +x yq
# opencode's asset arch tokens are x64/arm64.
RUN ARCH="$([ "${TARGETARCH}" = arm64 ] && echo arm64 || echo x64)" && wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/opencode.tar.gz "https://github.com/anomalyco/opencode/releases/download/${OPENCODE_VERSION}/opencode-linux-${ARCH}.tar.gz" && tar -xzf /tmp/opencode.tar.gz opencode && chmod +x opencode && rm /tmp/opencode.tar.gz

WORKDIR /root/.terraform.d/plugins/linux_${TARGETARCH}

RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/tf_sops.zip "https://github.com/carlpett/terraform-provider-sops/releases/download/v${TF_SOPS_VERSION}/terraform-provider-sops_${TF_SOPS_VERSION}_linux_${TARGETARCH}.zip" && unzip -q /tmp/tf_sops.zip && rm /tmp/tf_sops.zip

WORKDIR /root

# Helm plugins
# Helm 4 made `helm plugin install --verify` default to true; these community
# plugins ship no signatures, so installs fail with "plugin source does not
# support verification" unless we opt out with --verify=false.
RUN helm plugin install https://github.com/databus23/helm-diff --version "${HELM_DIFF_VERSION}" --verify=false
RUN helm plugin install https://github.com/aslafy-z/helm-git --version "${HELM_GIT_VERSION}" --verify=false
RUN helm plugin install https://github.com/jkroepke/helm-secrets --version "${HELM_SECRETS_VERSION}" --verify=false

# Trivy templates
RUN wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O gitlab.tpl "https://raw.githubusercontent.com/aquasecurity/trivy/v${TRIVY_VERSION}/contrib/gitlab.tpl"

# Claude Code
# The official installer is $HOME-relative (it drops the `claude` launcher in
# $HOME/.local/bin). Point HOME at a neutral, world-readable location for the
# install instead of root's home so Claude runs identically as root, as a baked
# non-root user, or as an arbitrary --user UID (the agent sandbox; see sandbox.sh
# / the README) — without poking a hole in /root's 0700. /opt is created 0755, so
# every UID can traverse it. Then symlink the launcher onto PATH like every other
# tool. (OpenCode needs none of this — it already lives in /usr/local/bin.)
RUN mkdir -p /opt/claude \
    && wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/claude-install.sh https://claude.ai/install.sh \
    && HOME=/opt/claude bash /tmp/claude-install.sh "${CLAUDE_CODE_VERSION}" \
    && rm /tmp/claude-install.sh \
    && ln -sf /opt/claude/.local/bin/claude /usr/local/bin/claude

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
# gcloud's tarball arch tokens are x86_64/arm (arm == arm64).
RUN if [[ "${CSP}" = "gcp" ]]; then ARCH="$([ "${TARGETARCH}" = arm64 ] && echo arm || echo x86_64)" && wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/gcloud.tar.gz "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GOOGLE_CLOUD_SDK_VERSION}-linux-${ARCH}.tar.gz" && tar -xzf /tmp/gcloud.tar.gz && rm /tmp/gcloud.tar.gz; fi

# DigitalOcean specific section
# doctl ships as a single binary, so no separate script is needed; drop it
# straight into /usr/local/bin to land on PATH like every other tool.
RUN if [[ "${CSP}" = "digitalocean" ]]; then wget -nv --tries=5 --waitretry=5 --retry-connrefused --timeout=30 -O /tmp/doctl.tar.gz "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-${TARGETARCH}.tar.gz" && tar -xzf /tmp/doctl.tar.gz -C /usr/local/bin doctl && rm /tmp/doctl.tar.gz; fi

# Minor cleanup
RUN rm -rvf /tmp/*

# Ensuring that final WORKDIR is /root
WORKDIR /root
