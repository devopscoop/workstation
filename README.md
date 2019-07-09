docker build -t registry.gitlab.com/dedevsecops/workstation .
docker push registry.gitlab.com/dedevsecops/workstation

To use this as your local workstation:

docker run -it --rm -v dedevsecops:/home/gitlab-runner registry.gitlab.com/dedevsecops/workstation bash
