# Workstation

This image is a collection of tools that are useful for CI/CD pipelines for Kubernetes clusters. Some pipeline jobs need git and kubectl; others need helm and kubectl; and others need git, terraform, and AWS CLI. Rather than maintaining a fleet of images with every permutation of tools needed for each particular job, we just have this one, big image with everything in it. A complete DevOps workstation in an image.

To save a little space, the image has different versions for different cloud service providers (CSPs), but we may merge all CSP tools back into one image later if there's demand for it.

## How to Use This Image

### Fork This Repo

Running random code you found on the Internet is not safe. You should fork this repo, review it yourself, and review again whenever you fetch upstream.

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

You can run this image on your local computer like this:
```
docker run -it --rm registry.gitlab.com/dedevsecops/workstation bash
```
