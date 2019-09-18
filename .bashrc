# If it looks like we're running it interactively using the admin.sh script,
# set a prompt and get our kubeconfig.
if [[ -f /mnt/env.sh ]]; then
  cd /mnt
  source env.sh
  export PS1="\u@${CLUSTER_NAME}:\w\$ "
  export KUBECONFIG=/mnt/kubeconfig
fi
export EDITOR=vim
