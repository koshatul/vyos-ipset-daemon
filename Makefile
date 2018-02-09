MATRIX_OS ?= darwin linux windows
MATRIX_ARCH ?= amd64

APP_VERSION = 0.1.0

DEBUG_ARGS = --ldflags "-X main.version=$(APP_VERSION)-debug -X main.gittag=$(shell git rev-parse --short HEAD) -X main.builddate=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")"
RELEASE_ARGS = -v -ldflags "-X main.version=$(APP_VERSION) -X main.gittag=$(shell git rev-parse --short HEAD) -X main.builddate=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") -s -w" -tags release

DOCKER_REPO := koshatul/ipsetd
DOCKER_TAG ?= $(APP_VERSION)-dev
DOCKER_REQ := src/cmd/ipsetd/* vendor

-include artifacts/make/docker/Makefile
-include artifacts/make/go/Makefile

artifacts/make/%/Makefile:
	curl -sf https://jmalloc.github.io/makefiles/fetch | bash /dev/stdin $*

.PHONY: install
install: vendor $(REQ) $(_SRC) | $(USE)
	$(eval PARTS := $(subst /, ,$*))
	$(eval BUILD := $(word 1,$(PARTS)))
	$(eval OS    := $(word 2,$(PARTS)))
	$(eval ARCH  := $(word 3,$(PARTS)))
	$(eval BIN   := $(word 4,$(PARTS)))
	$(eval ARGS  := $(if $(findstring debug,$(BUILD)),$(DEBUG_ARGS),$(RELEASE_ARGS)))

	CGO_ENABLED=$(CGO_ENABLED) GOOS="$(OS)" GOARCH="$(ARCH)" go install $(ARGS) "./src/cmd/..."

run.sh: artifacts/logs/docker/$(DOCKER_TAG)
	echo '#!/bin/bash' > run.sh
	echo 'make docker' >> run.sh
	echo 'docker run --privileged -ti --rm $(DOCKER_REPO):$(DOCKER_TAG) $$*' >> run.sh
	chmod 0755 run.sh
