# Workstation

This image has a small collection of applications that are useful for managing Kubernetes clusters. It created to be used as:

* a CI/CD worker (e.g., Gitlab runner, Jenkins, etc.)
* a common DevOps workstation, so everyone working with the cluster has the same environment

## CI/CD Worker

To use it as a CI/CD worker with Gitlab, just set your pipeline image to this Docker image. For an example, see the `image:` line in here:

https://gitlab.com/dedevsecops/k8s-eks-template/blob/master/.gitlab-ci.yml

## Common Workstation

This image is designed to be run using the [admin.sh](https://gitlab.com/dedevsecops/k8s-eks-template/blob/master/admin.sh) script in a Kubernetes repo that was based on [k8s-eks-template](https://gitlab.com/dedevsecops/k8s-eks-template). It requires an [env.sh](https://gitlab.com/dedevsecops/k8s-eks-template/blob/master/env.sh) and a kubeconfig.

However, it can be run without all of that stuff if you just want to run a Docker container that has a bunch of useful tools in it. You could run it like this:
```bash
docker run -it --rm registry.gitlab.com/dedevsecops/workstation bash
```
