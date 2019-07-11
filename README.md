# Workstation

This image was created to be used as:

* an image for a CI/CD pipeline (e.g., Gitlab runner, Jenkins, etc.)
* a common DevOps workstation, so everyone working with the cluster has the same environment

To use this as your local workstation, you should run it interactively, mount a volume named after the Kubernetes cluster you're managing, and specify the specific version of this image that works with that cluster. For example, if I had a Kubernetes cluster named "glados-dev", I would use a command like this:

```bash
docker run -it --rm -v glados-dev:/root registry.gitlab.com/dedevsecops/workstation:021cb63b bash
```

Set a prompt so you always know which cluster you're in. Edit your .profile:

```bash
vi .bashrc
```
And add this line (replace glados-dev with your cluster name):

```bash
export PS1='\u@glados-dev:\w\$ '
```

If you are managing an AWS EKS cluster with aws-iam-authenticator, you will need to add your AWS access key and secret to the volume:

```bash
aws configure
```

For example:

```bash
root@78f2629415a3:~# aws configure
AWS Access Key ID [None]: AKIBRH4B9YJZHCVAVWIU
AWS Secret Access Key [None]: 5fVftcURvP9yqLS7teLOucvM7oLuY0U2XBuVITbS
Default region name [None]: eu-west-3
Default output format [None]: 
root@78f2629415a3:~#
```

If you used eksctl to create the cluster, you need to get the kubeconfig file:

```bash
eksctl utils write-kubeconfig -n glados-dev
```
