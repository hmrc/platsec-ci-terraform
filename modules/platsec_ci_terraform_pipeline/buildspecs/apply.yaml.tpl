version: 0.2

env:
  shell: bash

phases:
  install:
    commands:
      - source scripts/check-tools.sh
      - pip3 install "pre-commit==$PRE_COMMIT_VERSION"
      - bash scripts/install-terraform.sh /usr/local/bin
  build:
    commands:
      - bash scripts/check-ci.sh
      - scripts/run.sh apply ${target}
