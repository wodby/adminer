-include env_make

ADMINER_VER ?= 6.3.0
ADMINER_MINOR_VER ?= $(shell echo "${ADMINER_VER}" | grep -oE '^[0-9]+\.[0-9]+')

ADMINER_LANG ?= en

# Adminer runs on the Apache variant of wodby/php, at one PHP version.
PHP_VER ?= 8.4
BASE_IMAGE_REVISION ?=

PLATFORM ?= linux/arm64

TAG ?= $(ADMINER_MINOR_VER)

REPO = wodby/adminer
NAME = adminer

ifneq ($(ARCH),)
	override TAG := $(TAG)-$(ARCH)
endif

.PHONY: build buildx-build buildx-push test push shell run start stop logs clean release

# Resolve the same pinned base image for every local and CI build target.
include base-images.mk
BASE_IMAGE_TAG = $(PHP_VER)-apache$(if $(BASE_IMAGE_REVISION),-$(BASE_IMAGE_REVISION))

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg BASE_IMAGE="$(BASE_IMAGE)" \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
	./

buildx-build:
	docker buildx build \
		--platform $(PLATFORM) \
		--build-arg BASE_IMAGE="$(BASE_IMAGE)" \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
		-t $(REPO):$(TAG) ./

buildx-push:
	docker buildx build --push \
		--platform $(PLATFORM) \
		--build-arg BASE_IMAGE="$(BASE_IMAGE)" \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
		-t $(REPO):$(TAG) ./

# CI combines the exact architecture images this workflow run pushed; see
# wodby/images arch-image-pins. Per-architecture tags are shared by every run,
# so an overlapping run may already have replaced one of them.
arch-image = $(if $(ARCH_IMAGE_PINS),$(or $(shell cat '$(ARCH_IMAGE_PINS)/$(subst :,_,$(subst /,_,$(1)))' 2>/dev/null),$(error No digest of $(1) was pushed by this workflow run)),$(1))

buildx-imagetools-create:
	docker buildx imagetools create -t $(REPO):$(TAG) \
				$(call arch-image,$(REPO):$(ADMINER_MINOR_VER)-amd64) \
				$(call arch-image,$(REPO):$(ADMINER_MINOR_VER)-arm64)
.PHONY: buildx-imagetools-create

test:
	cd ./tests/ && IMAGE=$(REPO):$(TAG) NAME=$(NAME) ./run.sh
#	@todo automate tests for mariadb/postgres via phantomjs/selenium
#	cd ./tests/mariadb && IMAGE=$(REPO):$(TAG) ./run.sh
#	cd ./tests/postgres && IMAGE=$(REPO):$(TAG) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push

# Print the image make builds and pushes; CI pushes exactly this reference.
.PHONY: image-ref
image-ref:
	@printf '%s\n' '$(REPO):$(TAG)'
