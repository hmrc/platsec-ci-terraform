# Shared local and CI checks
Terraform formatting, validation, TFLint, Checkov, Markdown lint,
ShellCheck, offline TruffleHog secret detection, and Trivy IaC checks.
ShellCheck follows sourced files. The shared tool settings are marked as Bash
and exempted from unused-variable warnings because their callers consume them.
Trivy (HIGH and CRITICAL), TFLint, and Checkov reject new findings while accepting
the reviewed legacy findings in `.checks-baseline.txt`. The same policy runs
locally, in Git hooks, and in the pipeline. Formatting, Terraform validation,
Markdown lint, ShellCheck, and TruffleHog remain fully blocking. Scanner execution
errors, malformed reports, and Checkov parsing errors also fail checks.

## Developer setup
Install Docker, Git, jq, and Python 3.11 or newer. Start Docker before running checks
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
TFLint uses a pinned tool version downloaded and cached by the upstream hook
on first use.

The three baseline hooks run `scripts/check_baseline.py`, which delegates through
`scripts/pre-commit.sh` to the upstream hooks pinned in `scripts/scan-hooks.yaml`.
Keep its upstream revision aligned with the main configuration when upgrading.
This sets up the Docker Trivy launcher automatically, including for plain
`pre-commit` and installed Git commit/push hooks. No manual Trivy `PATH` export
or native Trivy installation is required. Docker must be running.
Machine-readable reports are compared against the baseline; console output
shows accepted legacy counts and details of every new finding. The raw Trivy
scan uses `--exit-code=0` only so the comparator can decide which findings fail.
This does not make the outer baseline hook advisory.

```bash
pre-commit run terraform_trivy --all-files
```

```bash
aws-vault exec platsec-ci-RoleTerraformPlanner -- \
  terraform -chdir=ci init -backend=false
```
Docker and native Terraform use different provider platforms on macOS.
This initialization repairs local dependencies; it does not apply infrastructure.
`terraform_trivy` is enabled for Trivy scanning. It selects HIGH/CRITICAL findings and uses concise finding output.
Checkov uses local Terraform checks without downloading platform checks. 

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

## Fixing failures

### New findings only

Run checks normally; no enabling flag is needed:

```bash
make style-checks
```

The baseline records the existing findings, not a blanket rule or file exclusion.
A new resource or new rule violation fails even inside an existing legacy file.
Matching uses repository-relative file paths, rule IDs, resource identities,
severity, and occurrence counts, not line numbers. TFLint also fingerprints its
reported source expression, because not all lint findings have resource IDs.
Inserting unrelated lines does not invalidate accepted findings; adding another
instance of an accepted finding does fail. Renaming a file or resource can make
its old findings appear new and requires review.

All three scanners run across the repository, even for a single-file commit,
so local and CI comparisons use the same scope. This is a finding baseline,
not changed-line filtering: a still-existing accepted violation is allowed
when its resource is edited, but newly detected violations are blocked.
Rules explicitly disabled in scanner configuration remain disabled.

The baseline is tab-separated plain text with a header and one finding per row:
tool, occurrence count, file, rule, subject, severity, and TFLint fingerprint.
Fields containing tabs, newlines, or quotes use standard CSV-style quoting.

Commit `.checks-baseline.txt` with the hook configuration and scripts. Do not
regenerate it for normal code updates to make failures disappear. Fix new
findings instead. Baseline changes are policy changes and need code review;
use repository branch protection/reviewer ownership to prevent unreviewed
baseline or scanner-configuration changes.

Only when intentionally accepting reviewed existing debt or upgrading scanners:

```bash
python3 scripts/check_baseline.py update
git diff -- .checks-baseline.txt
make style-checks
```

The explicit update runs all scanners and replaces the baseline only if every
scan completes successfully. It also removes findings that have been fixed.
Normal checks never rewrite the baseline. Until removed, a fixed finding's
baseline entry could also accept an identical reintroduction.

Run the comparator regression tests with:

```bash
python3 -m unittest discover -s scripts -p 'test_check_baseline.py'
```

Use `make fmt` for Terraform or `make md-fix` for Markdown, inspect the changes,
stage them, and rerun the checks. Legacy `style-checks`, `fmt-check`, and
`md-check` targets delegate to pre-commit; they do not define separate linters.


## CI and enforcement

The repository-specific PR buildspec installs the pinned runner and Terraform,
then invokes
`bash scripts/check-ci.sh` before validation/planning. The deployment buildspec
does the same before each apply, before assuming the deployment role.
The same new-findings-only policy applies in both buildspecs; no pipeline-wide failure
suppression is used. Existing CodeBuild projects must use these buildspecs and
the pushed configuration for this policy to take effect.
CodePipeline archives without `.git` are checked in a disposable Git-initialized
copy including dotfiles. The actual deployment source is unchanged.
Docker, jq, Git, pip3, curl, unzip, and shasum must be available on the CodeBuild
image. Both buildspecs install Terraform in `/usr/local/bin` from the version in
`.terraform-version` before invoking the hooks.
Supply a clean source archive: its contents are authoritative, including source
files matching `.gitignore`. Generated Terraform artifacts remain excluded.
