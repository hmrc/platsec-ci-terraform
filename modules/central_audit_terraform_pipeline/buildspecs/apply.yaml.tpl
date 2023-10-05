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
      - |
        mkdir $${CODEBUILD_SRC_DIR}/tmp
        cd $${CODEBUILD_SRC_DIR}/tmp
        git clone "https://x-token-auth:$${GITHUB_API_TOKEN}@github.com/hmrc/central-audit-terraform.git"
        cd central-audit-terraform/
        git checkout $${COMMIT_ID}

      - |
        cd $${CODEBUILD_SRC_DIR}/tmp/central-audit-terraform
        scripts/apply.sh plan-${target}
