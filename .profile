# If it looks like we're running it interactively using the script,
# set a prompt and get our kubeconfig.
if [[ -f /mnt/env.sh ]]; then
  cd /mnt
  source env.sh
  export PS1="\u@${CLUSTER_NAME}:\w\$ "
fi

gpg-agent --daemon --enable-ssh-support

# These lines were copied from the .bashrc after manually running Google Cloud DSK install.sh:
if [ -f '/root/google-cloud-sdk/path.bash.inc' ]; then . '/root/google-cloud-sdk/path.bash.inc'; fi
if [ -f '/root/google-cloud-sdk/completion.bash.inc' ]; then . '/root/google-cloud-sdk/completion.bash.inc'; fi

# Bash Completion
source /usr/share/bash-completion/bash_completion

# Kubernetes Bash Autocompletion
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
