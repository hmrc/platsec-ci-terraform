version: 0.2

env:
  shell: bash
  secrets-manager:
    GITHUB_API_TOKEN: "/service_accounts/github_api_token"
  variables:
    TF_CLI_ARGS: "-no-color"

phases:
  build:
    commands:
      - ./scripts/apply.sh
