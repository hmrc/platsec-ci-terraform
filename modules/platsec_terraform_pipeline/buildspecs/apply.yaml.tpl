version: 0.2

env:
  shell: bash
  secrets-manager:
    GITHUB_API_TOKEN: "/service_accounts/github_api_token"

phases:
  build:
    commands:
      - |
        mkdir $${CODEBUILD_SRC_DIR}/tmp
        cd $${CODEBUILD_SRC_DIR}/tmp
        git clone "https://x-token-auth:$${GITHUB_API_TOKEN}@github.com/hmrc/platsec-terraform.git"
        cd platsec-terraform/
        git checkout $${COMMIT_ID}

      - |
        cd $${CODEBUILD_SRC_DIR}/tmp/platsec-terraform
        scripts/run.sh apply ${target}
