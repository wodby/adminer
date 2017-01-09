-include env_make

NS = wodby
VERSION ?= 4.2

REPO = adminer
NAME = adminer

.PHONY: build test push shell run start stop logs rm release

build:
	docker build -t $(NS)/$(REPO):$(VERSION) ./

test:
	docker ps | grep -c "$(NS)/$(REPO):$(VERSION)"

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

rm:
	docker rm $(NAME)

release: build
	make push -e VERSION=$(VERSION)

default: build
