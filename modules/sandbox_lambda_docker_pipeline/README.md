# sandbox_lambda_docker_pipeline

Module to build and deploy a dockerized lambda to sandbox only

The buildspec.yml in your source repo should produce an artefact called `docker.tar` that is a docker image
that was tagged with `container-release:local` and saved.

Sample buildspec.yml
```yaml
version: 0.2
phases:
  pre_build:
    commands:
      - make test
      - make lint
  build:
    commands:
      - make IMAGE_TAG=container-release:local package
      - docker save -o docker.tar container-release:local
artifacts:
  files:
    - docker.tar
```
