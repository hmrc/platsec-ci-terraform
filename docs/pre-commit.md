# Shared local and CI checks
Terraform formatting, validation, TFLint, Checkov, Markdown lint,
ShellCheck, offline TruffleHog secret detection, and Trivy IaC checks.

Trivy (HIGH and CRITICAL), TFLint, and Checkov reject new findings while accepting
the reviewed legacy findings in `.checks-baseline.txt`. 
The same policy runs locally, in Git hooks, and in the pipeline. Formatting, Terraform validation,
Markdown lint, ShellCheck, and TruffleHog remain fully blocking. 

## Developer setup
Install Docker, Git, and Python 3.11 or newer. Start Docker before running checks
```bash
uv tool install --upgrade pre-commit==4.7.0
bash scripts/pre-commit.sh install --install-hooks
```

Terraform formatting uses `terraform_fmt` from
`antonbabenko/pre-commit-terraform`, pinned in `.pre-commit-config.yaml`.

To install that version locally without replacing a system installation:

```bash
bash scripts/install-terraform.sh "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
```
The same repository also supplies `terraform_validate`,
`terraform_tflint`, `terraform_trivy`, and `terraform_checkov`.

The three baseline hooks all call scripts/check_baseline.py, which then runs scripts/pre-commit.sh. That script uses the upstream checks defined in scripts/scan-hooks.yaml. This also sets up the Docker-based Trivy launcher automatically,

The tool compares machine-readable Trivy results with the baseline. The output shows the accepted legacy counts and details of any new findings.


```bash
pre-commit run terraform_trivy --all-files
```

```bash
# Bash script which runs all the below checks at once
bash scripts/check-ci.sh

# Individual checks
bash scripts/pre-commit.sh run terraform_fmt --all-files
bash scripts/pre-commit.sh run terraform_validate --all-files
bash scripts/pre-commit.sh run terraform_tflint --all-files
bash scripts/pre-commit.sh run terraform_trivy --all-files
bash scripts/pre-commit.sh run terraform_checkov --all-files
bash scripts/pre-commit.sh run markdown --all-files
bash scripts/pre-commit.sh run trufflehog --all-files
bash scripts/pre-commit.sh run shellcheck --all-files
```

## CI and enforcement

The repository-specific PR buildspec installs the pinned runner and Terraform,
then invokes
`bash scripts/check-ci.sh` before validation/planning. The deployment buildspec
does the same before each apply, before assuming the deployment role.
The same new-findings-only policy applies in both buildspecs; no pipeline-wide failure
suppression is used.
