version: 0.2

env:
  shell: bash
  variables:
    TF_CLI_ARGS: "-no-color"

phases:
  build:
    commands:
      - ./scripts/run.sh apply ${target}
