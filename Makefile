
export AWS_DEFAULT_REGION=us-east-2

AWS_IMAGE=public.ecr.aws/dnxsolutions/aws-v2:latest
TERRAFORM_IMAGE=public.ecr.aws/dnxsolutions/terraform:latest

RUN_AWS_ENV    =docker run -i --rm --env-file=.env -v $(PWD):/work --entrypoint "" $(AWS_IMAGE)
RUN_TERRAFORM  =docker run -i --rm --env-file=.env -v $(PWD):/work -v ~/.aws:/root/.aws --entrypoint "" $(TERRAFORM_IMAGE)
RUN_AWS        =docker run -i --rm --env-file=.env -v $(PWD):/work -v ~/.aws:/root/.aws --entrypoint "" $(AWS_IMAGE)


OIDC_REQUIRED=
ifdef BITBUCKET_STEP_OIDC_TOKEN
	OIDC_REQUIRED=.oidc.token
	export AWS_WEB_IDENTITY_TOKEN_FILE=/work/.oidc.token
	export AWS_ROLE_ARN=arn:aws:iam::654137327726:role/PerxOIDCBitbucket
	RUN_AWS        =docker run --rm --env-file=.env -v $(PWD):/work --entrypoint "" $(AWS_IMAGE)
	RUN_TERRAFORM  =docker run --rm --env-file=.env -v $(PWD):/work --entrypoint "" $(TERRAFORM_IMAGE)
endif

env-%: # Check for specific environment variables
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1;fi

.env:
	cp .env.template .env
	echo >> .env
	touch .env.auth
	touch .env.assume

.oidc.token: env-BITBUCKET_STEP_OIDC_TOKEN
	$(shell echo $(BITBUCKET_STEP_OIDC_TOKEN) > $(PWD)/.oidc.token)
######################
# Terraform Commands
######################

_init:
	terraform init
	terraform workspace new $(WORKSPACE) 2>/dev/null; true # ignore if workspace already exists
	terraform workspace "select" $(WORKSPACE)

_lint:
	terraform fmt --recursive -check=true

_validate:
	terraform validate

_plan:
	terraform plan -out=.terraform-plan-$(WORKSPACE) -parallelism=50

_apply:
	terraform apply .terraform-plan-$(WORKSPACE)

_output:
	terraform output -json > output.json

_local_plan:
	terraform plan -out=.terraform-plan-$(WORKSPACE) -parallelism=50

######################
# Entry Points
######################

init: env-WORKSPACE $(OIDC_REQUIRED)
	$(RUN_TERRAFORM) make _init
.PHONY: init

lint: .env
	$(RUN_TERRAFORM) make _lint
.PHONY: lint

validate: .env
	$(RUN_TERRAFORM) make _validate
.PHONY: validate

apply: env-WORKSPACE
	$(RUN_TERRAFORM) make _apply
.PHONY: apply

plan: env-WORKSPACE
	$(RUN_TERRAFORM) make _plan
.PHONY: plan

output:
	@$(RUN_TERRAFORM) make _output
.PHONY: output

local_plan:
	$(RUN_TERRAFORM) make _local_plan
.PHONY: local_plan

######################
# Utilities
######################

shell: .env
	docker run -it --rm --env-file=.env.assume --env-file=.env -v $(PWD):/work -v $(HOME_FOLDER)/.aws:/root/.aws --entrypoint "/bin/bash" $(TERRAFORM_IMAGE)
.PHONY: shell
