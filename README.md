# Workstation

This image is a collection of applications that are useful for managing Kubernetes clusters. It was created because we wanted a consistent environment that could be used by humans and automated CI/CD workers (e.g., GitLab runner, Jenkins, etc.)

Gone are the days of "it works on my computer"! If everyone who managed a cluster uses this image, then we're all using the same versions of the same tools.

To save a little space for now, the image has different versions for different cloud service providers, but we may merge all CSPs back into one image later if there's demand for it.

## How to Use This Image

### Fork This Repo

Automatically running random code you found on the Intenret is not secure. You should fork this repo into your own GitLab group, which should trigger it to build an image. When the image is built, you should use your group's copy of the image. This will protect you in the event that someone accidentally breaks or maliciously changes this image in any way.

1. Fork this repo.
2. Clone repo on your computer.
3. Set an upstream remote so you can pull changes when you wish:
   ```
   git remote add upstream https://gitlab.com/dedevsecops/workstation.git
   ```
4. Whenever you wish to update your fork, run this:
   ```
   git fetch upstream
   git checkout master
   git merge upstream/master
   git push
   ```

### CI/CD Workers

To use it as a CI/CD worker with GitLab, just set your pipeline image to this Docker image. For an example, see the `image:` line in here:

https://gitlab.com/dedevsecops/k8s-eks-template/blob/master/.gitlab-ci.yml

### Humans

This image is designed to be run using the [admin.sh](https://gitlab.com/dedevsecops/k8s-eks-template/blob/master/admin.sh) script in a Kubernetes repo that was based on [k8s-eks-template](https://gitlab.com/dedevsecops/k8s-eks-template). It requires an [env.sh](https://gitlab.com/dedevsecops/k8s-eks-template/blob/master/env.sh) and a kubeconfig.

However, it can be run without all of that stuff if you just want to run a Docker container that has a bunch of useful tools in it. You could run it like this:
```bash
docker run -it --rm registry.gitlab.com/dedevsecops/workstation bash
```
