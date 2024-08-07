version: 0.2

env:
  shell: bash

phases:
  build:
    commands:
      - scripts/run.sh apply main
