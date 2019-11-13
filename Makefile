SHELL := /bin/bash

export TERRAFORM = /usr/local/bin/terraform

# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md docs/terraform.md

-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

build/deps:
	docker run -v $(CURDIR)/lambda:/var/task lambci/lambda:build-nodejs10.x npm install

build/zip: build/deps
	cd lambda && zip -rqX lambda.zip ./*
	mv lambda/lambda.zip lambda.zip

build/remove-deps:
	rm -rf lambda/node_modules

build/clean: build/remove-deps build/zip
	echo "Created lambda zip successfully"
