# If it looks like we're running it interactively using the admin.sh script,
# set a prompt and get our kubeconfig.
if [[ -f /mnt/env.sh ]]; then
  cd /mnt
  source env.sh
  export PS1="\u@${CLUSTER_NAME}:\w\$ "
  if [[ "$HELM_MAJOR_VERSION" ]]; then
    mv -v "/usr/local/bin/helm${HELM_MAJOR_VERSION}" /usr/local/bin/helm
  else
    echo 'WARNING: Missing HELM_MAJOR_VERSION environment variable. This means that the "helm" command is not available. Please set HELM_MAJOR_VERSION to "2" or "3" in the env.sh file. If you do not set it, you will have to use the commands "helm2" or "helm3".'
  fi
fi

gpg-agent --daemon --enable-ssh-support

# These lines were copied from the .bashrc after manually running Google Cloud DSK install.sh:
if [ -f '/root/google-cloud-sdk/path.bash.inc' ]; then . '/root/google-cloud-sdk/path.bash.inc'; fi
if [ -f '/root/google-cloud-sdk/completion.bash.inc' ]; then . '/root/google-cloud-sdk/completion.bash.inc'; fi
