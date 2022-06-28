export BASE_DIR=$(shell pwd)

help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Most of the real work of the build is in sub-project Makefiles.
include src/examples/module.mk
include src/validations/module.mk
include src/web/module.mk

.PHONY: help

all: clean test build  ## Complete clean build with tests

init: init-repo init-validations init-web  ## Initialize project dependencies

init-repo:
	git submodule update --init --recursive

clean: clean-dist clean-validations clean-web  ## Clean all

clean-dist:  ## Clean non-RCS-tracked dist files
	@echo "Cleaning dist..."
	git clean -xfd dist

test: test-validations test-web test-examples ## Test all

build: build-validations build-web dist  ## Build all artifacts and copy into dist directory
	# Symlink for Federalist
	ln -sf ./src/web/build _site

	# Copy validations
	mkdir -p dist/validations
	cp src/validations/target/rules/*.xsl dist/validations
	cp src/validations/rules/*.sch dist/validations

	# Symlink web build
	ln -sf ./src/web/build dist/web
