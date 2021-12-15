SHELL := /bin/bash

export TERRAFORM = /usr/local/bin/terraform

# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md docs/terraform.md

-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

lint:
	@cd examples/complete && terraform init && terraform validate
	@terraform fmt

build/deps:
	docker pull lambci/lambda:build-nodejs12.x
	docker run -v $(CURDIR)/lambda:/var/task lambci/lambda:build-nodejs12.x npm install --production

build/zip: build/lint build/deps
	cd lambda && zip -rqX lambda.zip ./*
	mv lambda/lambda.zip lambda.zip

build/remove-deps:
	@rm -rf lambda/node_modules

build/clean: build/remove-deps build/zip
	@echo -e "----------------------\nCreated lambda zip successfully"
