SHELL := /bin/bash

export TERRAFORM = /usr/local/bin/terraform

# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md docs/terraform.md

-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

lint:
	@cd examples/complete && terraform init && terraform validate
	@terraform fmt

build/lambda:
	docker pull public.ecr.aws/sam/build-nodejs14.x:1.66.0-20221129154622-x86_64
	docker run -v $(CURDIR)/lambda:/var/task public.ecr.aws/sam/build-nodejs14.x:1.66.0-20221129154622-x86_64 npm install --production

build/lambda-layer:
	docker pull public.ecr.aws/sam/build-nodejs14.x:1.66.0-20221129154622-x86_64
	docker run -v $(CURDIR)/lambda-layer:/var/task public.ecr.aws/sam/build-nodejs14.x:1.66.0-20221129154622-x86_64 make

build/lambda-zip: build/lambda
	cd lambda && zip -rqX lambda.zip ./*
	mv lambda/lambda.zip lambda.zip

build/lambda-layer-zip: build/lambda-layer
	cd lambda-layer && zip -rqX lambda-layer.zip ./*
	mv lambda-layer/lambda-layer.zip lambda-layer.zip
