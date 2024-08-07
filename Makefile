.ONESHELL: # Execute all instructions in a target in one shell
SHELL = /bin/bash
.SHELLFLAGS = -o errexit \
	-o nounset \
	-o pipefail \
	-c

export AWS_PROFILE = platsec-ci-RoleTerraformPlanner
export TERRAFORM_WORKSPACE = live

REMARK_LINT_VERSION = 0.2.1

ifneq (, $(strip $(shell command -v aws-vault)))
	AWS_PROFILE_CMD := aws-vault exec $${AWS_PROFILE} --
endif

# Terraform command accessible via Docker for user convenience and portability
# Any target that uses this command should have run "terraform" target
TF := docker run \
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
	tf-worker

# Build image based on hashicorp/terraform with custom dependencies
.PHONY: terraform
terraform:
	docker build \
		--tag tf-worker \
		--build-arg "TF_BASE_TAG=$(shell head -n1 .terraform-version)" \
		-f tf.Dockerfile \
		.

.PHONY: all-checks
all-checks: fmt-check validate md-check

# Format all terraform files
.PHONY: fmt
fmt: terraform
	@$(TF) fmt -recursive .

# Check if all files are formatted
.PHONY: fmt-check
fmt-check: terraform
	@$(TF) fmt -recursive -check .

.PHONY: md-check
md-check:
	@docker run --pull missing --rm -i -v $(PWD):/lint/input:ro zemanlx/remark-lint:${REMARK_LINT_VERSION} --frail .

# Update (to best of tools ability) md linter findings
.PHONY: md-fix
md-fix:
	@docker run --pull missing --rm -i -v $(PWD):/lint/input:rw zemanlx/remark-lint:${REMARK_LINT_VERSION} . -o

.PHONY: validate
validate: terraform
	@echo "Validating"
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) validate
	@echo -e "$@ OK\n"

plan: plan-main

.PHONY: plan
plan-main: export AWS_PROFILE := platsec-ci-RoleTerraformPlanner
plan: fmt-check
	@rm -f .terraform/terraform.tfstate
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) workspace select $(TERRAFORM_WORKSPACE)
	@$(AWS_PROFILE_CMD) $(TF) plan

apply: apply-main

.PHONY: apply
apply-main: export AWS_PROFILE := platsec-ci-RoleTerraformApplier
apply-main: fmt-check
	@rm -f .terraform/terraform.tfstate
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) workspace select $(TERRAFORM_WORKSPACE)
	@$(AWS_PROFILE_CMD) $(TF) apply

.PHONY: clean
clean:
	@docker system prune

.PHONY: plan-%
plan-bootstrap: export AWS_PROFILE := platsec-ci-RoleTerraformPlanner
plan-ci: export AWS_PROFILE := platsec-ci-RoleTerraformPlanner
plan-%: fmt-check
	@cd ./$*
	@rm -f .terraform/terraform.tfstate
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) plan

.PHONY: apply-%
apply-bootstrap: export AWS_PROFILE := platsec-ci-RoleTerraformApplier
apply-ci: export AWS_PROFILE := platsec-ci-RoleTerraformApplier
apply-%: fmt-check
	@cd ./$*
	@rm -f .terraform/terraform.tfstate
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) apply
