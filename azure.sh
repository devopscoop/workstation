#!/bin/bash

# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
# Removed "sudo" from commands, because we are already root.

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

apt-get update
apt-get install -y ca-certificates curl apt-transport-https gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
# Microsoft's azure-cli apt repo lags behind Ubuntu releases: it only publishes
# suites up to "noble" (24.04), so on a newer base (e.g. 26.04 "resolute")
# `lsb_release -cs` yields a codename with no Release file and apt-get update
# fails. Pin to the newest suite Microsoft ships; the azure-cli package is the
# same across suites, so the noble build installs fine on a later base.
# Bump this when Microsoft adds a newer suite at
# https://packages.microsoft.com/repos/azure-cli/dists/
AZ_REPO=noble
# dpkg's arch name (amd64/arm64) matches the apt repo's; the Microsoft azure-cli
# repo publishes both.
echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    tee /etc/apt/sources.list.d/azure-cli.list
apt-get update
apt-get install azure-cli
