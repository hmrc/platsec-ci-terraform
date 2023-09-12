.ONESHELL: # Execute all instructions in a target in one shell
SHELL = /bin/bash
.SHELLFLAGS = -o errexit \
	-o nounset \
	-o pipefail \
	-c

export AWS_PROFILE = platsec-ci-RoleTerraformProvisioner

REMARK_LINT_VERSION = 0.2.1

ifneq (, $(strip $(shell command -v aws-vault)))
	AWS_PROFILE_CMD := aws-vault exec $${AWS_PROFILE} --
endif

ifneq (, $(strip $(shell command -v aws-profile)))
	AWS_PROFILE_CMD := aws-profile --profile $${AWS_PROFILE}
endif

# TF = ${PWD}/scripts/terraform
TG := docker run \
	--rm \
	--interactive \
	--volume "${PWD}:${PWD}" \
	--env AWS_DEFAULT_REGION=eu-west-2 \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_SECRET_ACCESS_KEY \
	--env AWS_SESSION_TOKEN \
	--env TF_LOG \
	--user "$(shell id -u):$(shell id -g)" \
	--workdir "$${PWD}" \
	tg-worker

# Build image based on alpine/terragrunt with custom dependencies
.PHONY: terragrunt
terragrunt:
	docker build \
		--tag tg-worker \
		--build-arg "TF_BASE_TAG=$(shell head -n1 .terraform-version)" \
		-f tg.Dockerfile \
		.

.PHONY: all-checks
all-checks: fmt-check  md-check

# Format all terraform files
.PHONY: fmt
fmt: terragrunt
	@$(TG) terraform fmt -recursive .

# Check if all files are formatted
.PHONY: fmt-check
fmt-check: terragrunt
	@$(TG) terraform fmt -recursive -check .

.PHONY: md-check
md-check:
	@docker run --pull missing --rm -i -v $(PWD):/lint/input:ro zemanlx/remark-lint:${REMARK_LINT_VERSION} --frail .

# Update (to best of tools ability) md linter findings
.PHONY: md-fix
md-fix:
	@docker run --pull missing --rm -i -v $(PWD):/lint/input:rw zemanlx/remark-lint:${REMARK_LINT_VERSION} . -o

.PHONY: validate
validate: fmt
	@echo "Validating"
	@$(AWS_PROFILE_CMD) $(TG) scripts/run.sh validate
	@echo -e "$@ OK\n"

.PHONY: plan
plan: fmt
	@find . -type d -name '.terraform' | xargs -I {} rm -rf {}
	@$(AWS_PROFILE_CMD) $(TG) scripts/run.sh plan

apply: fmt
	@find . -type d -name '.terraform' | xargs -I {} rm -rf {}
	@$(AWS_PROFILE_CMD) $(TG) scripts/run.sh apply

.PHONY: clean
clean:
	@docker system prune
