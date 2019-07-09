docker build -t registry.gitlab.com/dedevsecops/workstation .
docker push registry.gitlab.com/dedevsecops/workstation

To use this as your local workstation:
docker run -it --name swisskube -v dedevsecops:/root registry.gitlab.com/dedevsecops/swisskube bash

