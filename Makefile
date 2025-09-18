-include env_make

ADMINER_VER ?= 5.4.0
ADMINER_MINOR_VER ?= $(shell echo "${ADMINER_VER}" | grep -oE '^[0-9]+\.[0-9]+')

ADMINER_LANG ?= en

PLATFORM ?= linux/arm64

TAG ?= $(ADMINER_MINOR_VER)

REPO = wodby/adminer
NAME = adminer

ifneq ($(ARCH),)
	override TAG := $(TAG)-$(ARCH)
endif

.PHONY: build buildx-build buildx-push test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
	./

buildx-build:
	docker buildx build \
		--platform $(PLATFORM) \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
		-t $(REPO):$(TAG) ./

buildx-push:
	docker buildx build --push \
		--platform $(PLATFORM) \
		--build-arg ADMINER_VER=$(ADMINER_VER) \
		-t $(REPO):$(TAG) ./

buildx-imagetools-create:
	docker buildx imagetools create -t $(REPO):$(TAG) \
				$(REPO):$(ADMINER_MINOR_VER)-amd64 \
				$(REPO):$(ADMINER_MINOR_VER)-arm64
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
