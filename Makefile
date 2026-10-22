.ONESHELL: # Execute all instructions in a target in one shell
SHELL = /bin/bash
.SHELLFLAGS = -o errexit \
	-o nounset \
	-o pipefail \
	-c

export AWS_PROFILE = platsec-ci-RoleTerraformPlanner

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

.PHONY: style-checks
style-checks:
	@bash scripts/check-ci.sh

# Format all terraform files
.PHONY: fmt
fmt: terraform
	@$(TF) fmt -recursive .

# Check if all files are formatted
.PHONY: fmt-check
fmt-check:
	@bash scripts/check-ci.sh terraform_fmt

.PHONY: md-check
md-check:
	@bash scripts/check-ci.sh markdown

# Update (to best of tools ability) md linter findings
.PHONY: md-fix
md-fix:
	@source scripts/check-tools.sh
	@docker run --rm --network none -v "$(PWD):/lint/input:rw" "$${MARKDOWN_IMAGE}" . -o

.PHONY: validate
validate: validate-bootstrap validate-ci validate-live

validate-%: terraform
	@cd ./$*
	@echo "Validating"
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) validate
	@echo -e "$@ OK\n"

.PHONY: plan
plan: plan-ci plan-live

.PHONY: plan-%
plan-ci: export AWS_PROFILE := platsec-ci-RoleTerraformPlanner
plan-live: export AWS_PROFILE := platsec-ci-RoleTerraformPlanner
plan-%: fmt
	@cd ./$*
	@rm -f .terraform/terraform.tfstate
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) plan -lock=false

.PHONY: apply
apply: apply-ci apply-live

.PHONY: apply-%
apply-ci: export AWS_PROFILE := platsec-ci-RoleTerraformApplier
apply-live: export AWS_PROFILE := platsec-ci-RoleTerraformApplier
apply-%: fmt-check terraform
	@cd ./$*
	@rm -f .terraform/terraform.tfstate
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) apply -auto-approve

.PHONY: clean
clean:
	@docker system prune

.PHONY: plan-bootstrap
plan-bootstrap: export AWS_PROFILE := platsec-ci-RoleTerraformPlanner
plan-bootstrap: fmt
	@cd ./bootstrap
	@rm -f .terraform/terraform.tfstate
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) plan -lock=false

.PHONY: apply-bootstrap
apply-bootstrap: export AWS_PROFILE := platsec-ci-RoleTerraformApplier
apply-bootstrap: fmt-check terraform
	@cd ./bootstrap
	@rm -f .terraform/terraform.tfstate
	@$(AWS_PROFILE_CMD) $(TF) init
	@$(AWS_PROFILE_CMD) $(TF) apply -auto-approve
