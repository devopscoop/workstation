# If it looks like we're running it interactively using the admin.sh script,
# set a prompt and get our kubeconfig.
if [[ -f /mnt/env.sh ]]; then
  source /mnt/env.sh
  export PS1="\u@${CLUSTER_NAME}:\w\$ "
  eksctl utils write-kubeconfig -n "${CLUSTER_NAME}"
fi
