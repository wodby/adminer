-include env_make

ADMINER_VER ?= 4.8.1
ADMINER_MINOR_VER ?= $(shell echo "${ADMINER_VER}" | grep -oE '^[0-9]+\.[0-9]+')

ADMINER_LANG ?= en

PLATFORM ?= linux/amd64

TAG ?= $(ADMINER_MINOR_VER)

PHP_VER ?= 7.4
BASE_IMAGE_TAG = $(PHP_VER)

REPO = wodby/adminer
NAME = adminer-$(ADMINER_MINOR_VER)

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

.PHONY: build buildx-build buildx-build-amd64 buildx-push test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
	./

# --load doesn't work with multiple platforms https://github.com/docker/buildx/issues/59
# we need to save cache to run tests first.
buildx-build-amd64:
	docker buildx build \
		--platform linux/amd64 \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
		--load \
		-t $(REPO):$(TAG) \
		./

buildx-build:
	docker buildx build \
		--platform $(PLATFORM) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
		-t $(REPO):$(TAG) ./

buildx-push:
	docker buildx build --push \
		--platform $(PLATFORM) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
		-t $(REPO):$(TAG) ./

test:
#	cd ./tests/ && IMAGE=$(REPO):$(TAG) NAME=$(NAME) ./run.sh
#	@todo automate tests for mariadb/postgres via phantomjs/selenium
	cd ./tests/mariadb && IMAGE=$(REPO):$(TAG) ./run.sh
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
